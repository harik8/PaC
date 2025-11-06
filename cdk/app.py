#!/usr/bin/env python3
import os
import aws_cdk as cdk

from cdk.test_stack import TestStack
from cdk.s3_stack import S3Stack
# from cdk.vpc_stack import VpcStack
# from cdk.eks_stack import EksStack
# from cdk.rds_stack import RdsStack
# from cdk.lambda_stack import LambdaStack

# from dotenv import load_dotenv

# load_dotenv()

# aws_account_id   = os.getenv('AWS_ACCOUNT_ID')
# aws_region       = os.getenv('AWS_REGION')
# aws_account_name = os.getenv('AWS_ACCOUNT_NAME')

app = cdk.App()
TestStack(app, "h-cdk-test",
  env=cdk.Environment(account='****', region='***'),
)

S3Stack(app, "h-tofu-state",
  env=cdk.Environment(account='****', region='****'),
)

# vpc = VpcStack(app, f"{aws_account_name}-vpc",
#   env=cdk.Environment(account=aws_account_id, region=aws_region)
# )

# eks = EksStack(app, f"{aws_account_name}-eks",
#   vpc=vpc,
#   account=aws_account_id,
#   env=cdk.Environment(account=aws_account_id, region=aws_region)
# )

# rds = RdsStack(app, f"{aws_account_name}-rds",
#   vpc=vpc,
#   account=aws_account_id,
#   env=cdk.Environment(account=aws_account_id, region=aws_region)
# )

# _lambda = LambdaStack(app, f"{aws_account_name}-lambda",
#   env=cdk.Environment(account=aws_account_id, region=aws_region)
# )

app.synth()
