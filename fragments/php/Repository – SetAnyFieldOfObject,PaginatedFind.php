<?php

namespace AppBundle\Repository;

use AppBundle\Entity\Company;
use AppBundle\Entity\Inquery;
use AppBundle\Entity\InqueryReceiver;
use AppBundle\Entity\User;
use AppBundle\Entity\Tblmessages;
use AppBundle\Entity\InquerySubmitStatus;
use Doctrine\ORM\Query\Expr\Join;

class InqueryRepository extends \Doctrine\ORM\EntityRepository
{
    /**
     * Returns some partial data from "$count" inqueries of status "$status",
     * starting at the number "$index" amongst them
     * @param string $status
     * @param int $index index of the first
     * @param int $count
     * @return mixed
     */
    public function findSummaryNewList(int $status, int $index, int $count = 0)
    {
        $request = $this->createQueryBuilder('inq');
        $expr = $request->expr();

        $request->select(
            'inq.id',
            'u.firstName as userFirstName',
            'u.lasterName as userLastName',
            'u.userName',
            'u.description as userDescription',
            'inq.message',
            'status.inqueryStatus as progressionStatus',
            'inq.submissionDate',
            'inq.responseTime',
            'u.userpicture'
        )
            ->join(
                User::class,
                'u',
                Join::WITH,
                $expr->eq('inq.user', 'u.id')
            )
            ->join(
                InquerySubmitStatus::class,
                'status',
                Join::WITH,
                $expr->eq('inq.status', 'status.id')
            )
         ->where(
             $expr->eq('status.id', ':status')
         )
            ->orderBy('inq.submissionDate', 'DESC')
            ->setFirstResult($index);

        if ($count !== 0) {
            $request->setMaxResults($count);
        }


        $request->setParameter('status', $status);

        return $request->getQuery()->execute();
    }

    /**
     * Returns comprehensive data (including the professionnal who answered to
     * the inquery) from "$count" inqueries of status "$status",
     * starting at the number "$index" amongst them
     * @param string $status
     * @param int $index index of the first
     * @param int $count
     */
    public function findSummaryCurrentList(int $excludedStatus, int $index, int $count = 0)
    {
        $request = $this->createQueryBuilder('inq');
        $expr = $request->expr();

        $request->select(
            'inq.id',
            'u.firstName as userFirstName',
            'u.lasterName as userLastName',
            'u.userName',
            'u.description as userDescription',
            'inq.message',
            'status.inqueryStatus as progressionStatus',
            'inq.submissionDate',
            'inq.responseTime',
            'u.userpicture'
        )
        ->join(
            User::class,
            'u',
            Join::WITH,
            $expr->eq('inq.user', 'u.id')
        )
        ->join(
            InquerySubmitStatus::class,
            'status',
            Join::WITH,
            $expr->eq('inq.status', 'status.id')
        )
        ->where(
            $expr->neq('status.id', ':status')
        )
        ->orderBy('inq.submissionDate', 'DESC')
        ->setFirstResult($index);

        if ($count !== 0) {
            $request->setMaxResults($count);
        }

        $request->setParameter('status', $excludedStatus);
        $inqueryList = $request->getQuery()->execute();


        # get the company list for each inquery
        #
        $repository = $this->getEntityManager()->getRepository(Company::class);

        $l = count($inqueryList);
        for ($i = 0; $i < $l; $i++) {
            $request = $repository->createQueryBuilder('c');
            $expr = $request->expr();

            $request->select(
                'c.name as name',
                'c.logo'
            )
            ->join(
                InqueryReceiver::class,
                'ireceiver',
                Join::WITH,
                $expr->eq('c.id', 'ireceiver.company')
            )
            ->where($expr->eq('ireceiver.inquery', ':inqueryId'));

            $request->setParameter('inqueryId', $inqueryList[$i]['id']);

            $companyList = $request->getQuery()->execute();
            $inqueryList[$i]['companyList'] = $companyList;
        }

        return $inqueryList;
    }

    public function updateField(string $fieldName, $newValue, int $id) #: bool
    {
        $request = $this->createQueryBuilder('inq');

        $request->update()
            ->set('inq.' . $fieldName, $newValue)
            ->where($request->expr()->eq('inq.id', ':id'))
            ->setParameter('id', $id);

        return $request->getQuery()->execute();
    }
}

