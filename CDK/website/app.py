#!/usr/bin/env python3
import os

import aws_cdk as cdk

from website.website_stack import WebsiteStack

app = cdk.App()

# Example Dev and Prod stacks are in different accounts, so we need to specify the account and region for each stack
WebsiteStack(
    app,
    "DevWebsiteStack",
    "dev-website-",
    env=cdk.Environment(account="304851244121", region="us-west-2"),
)
WebsiteStack(
    app,
    "ProdWebsiteStack",
    "prod-website-",
    env=cdk.Environment(account="590183902691", region="us-west-2"),
)


app.synth()
