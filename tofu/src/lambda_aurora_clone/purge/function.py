import boto3
import logging
import os
from datetime import datetime, timedelta

logger = logging.getLogger()
logger.setLevel("INFO")

def lambda_handler(event, context):
    rds = boto3.client('rds')
    clusters = rds.describe_db_clusters()

    clone_clusters = []
    clone_instances = []

    try:
        # Read the clusters and filter based on,
        # 1. Tag Stage with value from environment variable STAGE
        # 2. DBClusterIdentifier contains 'clone' -> indicates its a clone
        # 3. CloneGroupId is not None -> indicates its a clone
        # 4. ClusterCreateTime is older than RETENTION_DAYS from environment variable        
        for cluster in clusters['DBClusters']:
            for tags in cluster['TagList']:
                if tags.get('Key') == 'Stage' and tags.get('Value') == os.environ['STAGE'] and 'clone' in cluster['DBClusterIdentifier'] and cluster['CloneGroupId'] is not None:
                    logger.info(f"Found Clone Cluster: {cluster['DBClusterIdentifier']} with Creation Time: {cluster['ClusterCreateTime']}")
                    # gets the current time in the same timezone as creation_time
                    if cluster['ClusterCreateTime'] < datetime.now(cluster['ClusterCreateTime'].tzinfo) - timedelta(days=int(os.getenv('RETENTION_DAYS'))):
                        clone_clusters.append(cluster['DBClusterIdentifier'])
                        clone_instances.append(cluster['DBClusterMembers'][0]['DBInstanceIdentifier'])

        logger.info(f"List of Clone Clusters : {clone_clusters}")
        logger.info(f"List of Clone Cluster Instances : {clone_instances}")

        for instance in clone_instances:
            logger.info(f"Deleting an instance of a clone cluster: {instance}")
            rds.delete_db_instance(
                DBInstanceIdentifier=instance,
                SkipFinalSnapshot=True, 
            DeleteAutomatedBackups=True
        )

        for cluster in clone_clusters:
            logger.info(f"Deleting Clone Cluster : {cluster}")
            rds.delete_db_cluster(
                DBClusterIdentifier=cluster,
                SkipFinalSnapshot=True,
                DeleteAutomatedBackups=True
            )

        return {
            'statusCode': 200,
            }
    except Exception as e:
        logger.error(f"Error occurred: {str(e)}")
        return {
            'statusCode': 500,
        }
    
