import boto3
import json
import os
import logging

logger = logging.getLogger()
logger.setLevel("INFO")

def lambda_handler(event, context):
    rds = boto3.client('rds')

    pr_number          = event['PR_NUMBER']
    src_db_cluster     = event['SOURCE_DB_CLUSTER']
    restore_db_cluster = f"{src_db_cluster}-clone-{pr_number}"

    logger.info(f"Event payload -> pr_number: [{pr_number}], source_db_cluster: [{src_db_cluster}]")

    try:

        src_cluster  = rds.describe_db_clusters(DBClusterIdentifier=src_db_cluster)['DBClusters'][0]
        sg_ids       = [sg['VpcSecurityGroupId'] for sg in src_cluster['VpcSecurityGroups']]
        subnet_group = src_cluster['DBSubnetGroup']

        # Clone the cluster
        clusters = rds.restore_db_cluster_to_point_in_time(
            DBClusterIdentifier=restore_db_cluster,
            SourceDBClusterIdentifier=f"{src_db_cluster}",
            RestoreType='copy-on-write',
            UseLatestRestorableTime=True,
            VpcSecurityGroupIds=sg_ids,
            DBSubnetGroupName=subnet_group
        )

        logger.info(f"Intitated cluster restore for : [{restore_db_cluster}]")

        # Get engine from cluster response
        engine = clusters['DBCluster']['Engine']

        # Create a writer instance and add it to the cloned cluster
        instances = rds.create_db_instance(
            DBInstanceIdentifier=f"{restore_db_cluster}-{pr_number}",
            DBClusterIdentifier=restore_db_cluster,
            DBInstanceClass=os.environ['DB_INSTANCE_CLASS'],
            Engine=engine
        )

        logger.info(f"Adding instance to cluster : [{restore_db_cluster}]")

        return {
            'statusCode': 200,
            'body': json.dumps({
                'cluster_id': f"{restore_db_cluster}",
                'cluster_status': clusters['DBCluster']['Status'],
                'endpoint': clusters['DBCluster']['Endpoint'],
                'instance_id': f"{restore_db_cluster}-{pr_number}",
                'message': 'CLUSTER_RESTORE_INITIATED'
            })
        }
    except rds.exceptions.DBClusterAlreadyExistsFault as existsFault:
        cluster = rds.describe_db_clusters (
            DBClusterIdentifier=f"{src_db_cluster}-clone-{pr_number}"
        )
        logger.info(f"Cluster already exists: [%s]", restore_db_cluster)
        return {
            'statusCode': 200,
            'body': json.dumps({
                'cluster_id': f"{restore_db_cluster}",
                'cluster_status': cluster['DBClusters'][0]['Status'],
                'endpoint': cluster['DBClusters'][0]['Endpoint'],
                'message': 'CLUSTER_ALREADY_EXISTS'
            })
        }
    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps({
                'error': str(e)
            })
        }