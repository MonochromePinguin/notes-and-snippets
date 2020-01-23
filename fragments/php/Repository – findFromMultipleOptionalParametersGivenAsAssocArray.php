<?php

namespace AppBundle\Repository;

use Doctrine\ORM\Query\Expr\Join;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\ParameterBag;
use AppBundle\Entity\CompanyType;
use AppBundle\Entity\Company;


class CompanyRepository extends \Doctrine\ORM\EntityRepository
{
    # These 4 arrays contains the categories of available parameters given
    # into the JSON payload of the searchAction() method:

    # MANDATORY PARAMETERS:
    # pairs of field names / type for validation
    #
    const SEARCH_NEEDED_PARAMS = [
    //TODO: if you want to make these parameters mandatory again, just uncomment them
        /*'lat' => 'numeric',
        'lng' => 'numeric',
        'radius' => 'numeric'*/
    ];

    # GEOLOCATION PARAMETERS:
    # theses fields are taken into account
    # only if all of them are present
    const ALL_OR_NONE_GEOLOC_PARAMS = [
        'lat' => 'numeric',
        'lng' => 'numeric',
        'radius' => 'numeric'
    ];

    # OPTIONAL PARAMETERS DEREFENRENCING VALUES OF ANOTHER ENTITY
    # Each field of the request listed in this array can be either a string
    # or an array of strings
    # Each record is of the format
    #   name of the field in the "Company" entity =>
    #       target: target entity
    #       targetId: name of the primary key in the target entity
    #       lookedField: field tested inside the target entity
    #       alias: an alias for building the request
    const MULTIPLE_CRITERIAS = [
        'companytype' => [
            'target' => CompanyType::class,
            'targetId' => 'id',
            'lookedField' => 'companytype',
            'alias' => 'compT'
        ]
    ];

    # OPTIONAL PARAMETERS INSIDE THE COMPANY ENTITY:
    # simple fields with continuous values:
    # pairs of field names / type for validation
    const SINGLE_CRITERIAS = [
        'country' => 'string',
        'region' => 'string',
        'city' => 'string',
        'postalcode' => 'string',
        'street' => 'string',
        'language' => 'int'
    ];

    # ALLOWED FIELDS FOR FULL TEXT SEARCH (the "fullText" key)
    const FULL_TEXT_SEARCH_ALLOWED = [
        'name', 'fulladdress', 'country', 'city', 'postalcode', 'street',
        'lat', 'lng', 'phone1', 'phone2', 'email', 'contactperson', 'homepage1',
        'legalrepresentativefirstname', 'legalrepresentativelastname',
        'legalrepresentativestreet', 'legalrepresentativecity',
        'legalrepresentativepostalcode', 'legalrepresentativeregion',
        'legalrepresentativecountry', 'representativebirthday',
        'googleplaceid', 'logo', 'description'
    ];

    # THE "count" PARAMETER (LIMITING THE RESULT COUNT) IS NOT LISTED HERE
    # AND WILL BE USED WHILE BUILDING THE QUERY


    public function getAllUsedTypes()
    {
        $qb = $this->createQueryBuilder('co');

        $qb->select('compT.companytype')
            ->join(CompanyType::class, 'compT')
            ->where(
                $qb->expr()->eq(
                    'co.companytype',
                    'compT.id'
                )
            )
            ->distinct()
            ->orderBy('compT.companytype');

        return $qb->getQuery()->getResult();
    }

    /**
     * This function returns a list of companies corresponding to the given
     * criterias (or no filter at all if given an empty array as $request)
     * given in the form of a key/value into an assoc array
     *
     * @param ParameterBag $Request
     * @return mixed
     */
    public function findFromParameters(ParameterBag $request, $serializer)
    {
        # all validated parameters are inserted into this array
        $parameters = [];
        $resultCount = 0;

        # input validation for mandatory parameters
        #
        foreach (self::SEARCH_NEEDED_PARAMS as $param => $type) {
            $isFunc = '\is_' . $type;

            if (empty($isFunc($request->get($param)))) {
                return new JsonResponse([
                    'code' => 400,
                    'message' => 'Bad Request: lack of needed field ' . $param
                ]);
            }

            $parameters[$param] = $request->get($param);
        }

        # input validation for gelocation parameters
        #
        $geolocation = true;
        foreach (self::ALL_OR_NONE_GEOLOC_PARAMS as $key => $type) {
            $isFunc = '\is_' . $type;

            if (empty($isFunc($request->get($key)))) {
                $geolocation = false;
                break;
            }
        }
        if ($geolocation) {
            $lat = $request->get('lat');
            $lng = $request->get('lng');
            $radius = $request->get('radius');
        }

        # input validation – other optional fields
        #

        foreach (self::MULTIPLE_CRITERIAS as $key => $value) {
            if (null != $request->get($key)) {
                //TODO: add type validation of the content
                $parameters[$key] = $request->get($key);
            }
        }

        foreach (self::SINGLE_CRITERIAS as $key => $awaitedType) {
            $isFunc = 'is_' . $awaitedType;

            if (null != $request->get($key)) {
                $value = $request->get($key);

                if (!$isFunc($value)) {
                    return new JsonResponse([
                        'code' => 400,
                        'message' => 'Bad Request: invalid type of field "' . $key . '"'
                    ]);
                }

                $parameters[$key] = $request->get($key);
            }
        }

        if (null != $request->get('count')) {
            $resultCount = $request->get('count');

            if (!is_integer($resultCount) || ($resultCount <= 0)) {
                return new JsonResponse([
                    'code' => 400,
                    'message' => 'Bad Request: invalid type of field "count"'
                ]);
            }
        }

        #query building
        #

        $qb = $this->createQueryBuilder('co');
        $expr = $qb->expr();

        $query = $qb->select('co.id,
            co.name,
            co.fulladdress,
            co.country,
            co.phone1,
            co.phone2,
            co.email,
            co.homepage1,
            co.logo,
            compT.companytype,
            co.lat,
            co.lng'
            . ($geolocation ?
                ', GEO_DISTANCE(:centerLat, :centerLng, co.lat, co.lng) AS distance'
                : ''
              ));

        #we always show "compT.companytype", whether it is included or not as optional parameter,
        # so it is possible we need to join it here
        if (!array_key_exists('companytype', $parameters)) {
            $query->join(
                CompanyType::class,
                'compT',
                Join::WITH,
                $expr->eq(
                    'co.companytype',
                    'compT.id'
                )
            );
        }

        if ($geolocation) {
            $query->where($expr->gte(
                ':radiusInKm',
                'GEO_DISTANCE(:centerLat, :centerLng, co.lat, co.lng)'
            ))
            ->setParameter('centerLat', $lat)
            ->setParameter('centerLng', $lng)
            ->setParameter('radiusInKm', $radius)
            ->orderBy('distance');
        }

        #criterias allowed to contains either a string or an array of strings,
        # and dereferencing a related entity
        foreach (self::MULTIPLE_CRITERIAS as $key => $info) {
            if (array_key_exists($key, $parameters)) {
                $valueArray = $parameters[$key];
                if (!is_array($valueArray)) {
                    $valueArray = [ $valueArray ];
                }

                $target = $info['target'];
                $alias = $info['alias'];
                $targetId = $info['targetId'];
                $field = $info['lookedField'];

                $query->join(
                    $target,
                    $alias,
                    Join::WITH,
                    $expr->eq(
                        'co.' . $key,
                        $alias . '.' . $targetId
                    )
                );
                $expr = $query->expr();

                #We are building a WHERE ( name = x OR name = y OR ... ) AND ...
                $orCond = $expr->orX();

                ## AND for the first item of the loop,
                ## OR for the others : Doctrine will treat them as AND( ... OR ... )
                foreach ($valueArray as $value) {
                    $orCond->add(
                        $expr->eq(
                            $alias . '.' . $field,
                            $expr->literal($value)
                        )
                    );
                }
                $query->andWhere($orCond);
            }
        }

        #criterias looking directly inside fields of Inquery
        foreach (self::SINGLE_CRITERIAS as $criteria) {
            if (array_key_exists($criteria, self::SINGLE_CRITERIAS)) {
                $query->andWhere(
                    $expr->eq(
                        'co.' . $criteria,
                        $expr->literal($parameters[$criteria])
                    )
                );
            }
        }

        #full text search inside a set of fields
        if (null != $request->get('fullText')) {
            $orCond = $expr->orX();
            $literal = $expr->literal('%' . $request->get('fullText') . '%');

            foreach (self::FULL_TEXT_SEARCH_ALLOWED as $field) {
                $orCond->add(
                    $expr->like(
                        'co.' . $field,
                        $literal
                    )
                );
            }
            $query->andWhere($orCond);
        }

        if ($resultCount > 0) {
            $query->setMaxResults($resultCount);
        }

        return JsonResponse::fromJsonString(
            $serializer->serialize(
                $qb->getQuery()->getResult(),
                'json'
            )
        );
    }



    public function findCompaniesEmail($companiesList)
    {

        $request = $this->createQueryBuilder('comp');
        $request->select('comp.email');
        $request->expr()->in('comp.id', (':id'));
        $request->where('comp.id IN (:ids)')
                ->setParameter(':ids', $companiesList, \Doctrine\DBAL\Connection::PARAM_STR_ARRAY);



        $query = $request->getQuery();
        return $query->getResult();
    }
}

