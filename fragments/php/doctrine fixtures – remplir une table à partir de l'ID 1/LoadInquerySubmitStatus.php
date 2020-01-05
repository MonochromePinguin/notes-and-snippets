<?php

namespace AppBundle\DataFixtures;

use AppBundle\Entity\InquerySubmitStatus;
use Doctrine\Common\Persistence\ObjectManager;
use Faker\Factory;
use Doctrine\Common\DataFixtures\AbstractFixture;
use Symfony\Component\DependencyInjection\ContainerAwareInterface;
use Symfony\Component\DependencyInjection\ContainerInterface;

# to allow getting the Doctrine reference, this class is declared as a service ...
# into "config_dev.yml"!
#
# It is a child of AbstractFixture instead of Fixture, and so must implement
# the "setContainer() method"
#
class LoadInquerySubmitStatus extends AbstractFixture implements ContainerAwareInterface
{
    public const NB_INQUERYSTATUS = 6;
    public const STATUS_NEW = 'Received';

    private const INQUERY_NAMES = [
        '1' => 'Received',
        '2' => 'Sent to professionnal',
        '3' => 'Clarification',
        '4' => 'Responded',
        '5' => 'Completed',
        '6' => 'deleted and inexistent in the real DB',
        '7' => 'Cancelled'
    ];

    public static $allowedRefs = [ 1, 2, 3, 4, 5, 7 ];

    private $container;

    public function setContainer(ContainerInterface $container = null)
    {
        $this->container = $container;
    }


    public function load(ObjectManager $manager)
    {
        $faker = Factory::create();

        #To follow the official structure of the DB, we must use specific IDs:
        # 1,2,3,4,5 and 7
        $em = $this-> container->get("doctrine")->getManager();
        $tableName = $em->getClassMetadata(InquerySubmitStatus::class)->getTableName();
        $connection = $em->getConnection();

        # THIS IS NOT PROBABLY NOT PORTABLE! BUT IT WORKS WITH MYSQL
        $connection->exec("ALTER TABLE " . $tableName . " AUTO_INCREMENT = 1;");

        foreach (self::INQUERY_NAMES as $id => $name) {
            $status = new InquerySubmitStatus();

            $status->setInqueryStatus($name);
            $status->setComment($faker->text(255));
            $status->setTimestamp(new \DateTime('now'));

            $manager->persist($status);

            if (in_array($id, self::$allowedRefs)) {
                $this->addReference('inquerySubmitStatus' . $id, $status);
            }
        }

        $manager->flush();

        # the column of Id 6 must not exist
        $connection->exec('DELETE FROM ' . $tableName . ' WHERE InqueryStatusID = 6');
    }
}

