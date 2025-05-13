# Group
#Administartors
resource "aws_iam_group" "Create_group_Administrators" {
  name = "Administrators"
  path = "/"
}

resource "aws_iam_policy" "Add_AdministratorAccess_policy" {
  name        = "AdministratorAccess"
  description = "AdministratorAccess"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "*"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_group_policy_attachment" "Attach_AdministratorAccess" {
  group      = aws_iam_group.Create_group_Administrators.name
  policy_arn = aws_iam_policy.Add_AdministratorAccess_policy.arn
}

#Developers
resource "aws_iam_group" "Create_group_Developers" {
  name = "Developers"
  path = "/"
}

resource "aws_iam_policy" "Add_AmazonEC2FullAccess_policy" {
  name        = "AmazonEC2FullAccess"
  description = "AmazonEC2FullAccess"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : "ec2:*",
        "Effect" : "Allow",
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : "elasticloadbalancing:*",
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : "cloudwatch:*",
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : "autoscaling:*",
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : "iam:CreateServiceLinkedRole",
        "Resource" : "*",
        "Condition" : {
          "StringEquals" : {
            "iam:AWSServiceName" : [
              "autoscaling.amazonaws.com",
              "ec2scheduled.amazonaws.com",
              "elasticloadbalancing.amazonaws.com",
              "spot.amazonaws.com",
              "spotfleet.amazonaws.com",
              "transitgateway.amazonaws.com"
            ]
          }
        }
      }
    ]
  })
}

resource "aws_iam_policy" "Add_AmazonS3ReadOnlyAccess_policy" {
  name        = "AmazonS3ReadOnlyAccess"
  description = "AmazonS3ReadOnlyAccess"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:Get*",
          "s3:List*",
          "s3:Describe*",
          "s3-object-lambda:Get*",
          "s3-object-lambda:List*"
        ],
        "Resource" : [
          "arn:aws:s3:::oleg.zhemanov",
          "arn:aws:s3:::oleg.zhemanov/*"
        ]
      }
    ]
  })
}

resource "aws_iam_policy" "Add_AWSLambda_FullAccess_policy" {
  name        = "AWSLambda_FullAccess"
  description = "AWSLambda_FullAccess"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "cloudformation:DescribeStacks",
          "cloudformation:ListStackResources",
          "cloudwatch:ListMetrics",
          "cloudwatch:GetMetricData",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeSubnets",
          "ec2:DescribeVpcs",
          "kms:ListAliases",
          "iam:GetPolicy",
          "iam:GetPolicyVersion",
          "iam:GetRole",
          "iam:GetRolePolicy",
          "iam:ListAttachedRolePolicies",
          "iam:ListRolePolicies",
          "iam:ListRoles",
          "lambda:*",
          "logs:DescribeLogGroups",
          "states:DescribeStateMachine",
          "states:ListStateMachines",
          "tag:GetResources",
          "xray:GetTraceSummaries",
          "xray:BatchGetTraces"
        ],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : "iam:PassRole",
        "Resource" : "*",
        "Condition" : {
          "StringEquals" : {
            "iam:PassedToService" : "lambda.amazonaws.com"
          }
        }
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "logs:DescribeLogStreams",
          "logs:GetLogEvents",
          "logs:FilterLogEvents",
          "logs:StartLiveTail",
          "logs:StopLiveTail"
        ],
        "Resource" : "arn:aws:logs:*:*:log-group:/aws/lambda/*"
      }
    ]
  })
}

resource "aws_iam_group_policy_attachment" "Attach_AmazonEC2FullAccess_policy" {
  group      = aws_iam_group.Create_group_Developers.name
  policy_arn = aws_iam_policy.Add_AmazonEC2FullAccess_policy.arn
}

resource "aws_iam_group_policy_attachment" "Attach_AmazonS3FullAccess_policy" {
  group      = aws_iam_group.Create_group_Developers.name
  policy_arn = aws_iam_policy.Add_AmazonS3ReadOnlyAccess_policy.arn
}

resource "aws_iam_group_policy_attachment" "Attach_AWSLambda_FullAccess_policy" {
  group      = aws_iam_group.Create_group_Developers.name
  policy_arn = aws_iam_policy.Add_AWSLambda_FullAccess_policy.arn
}

#DevOps
resource "aws_iam_group" "Create_group_DevOps" {
  name = "DevOps"
  path = "/"
}

resource "aws_iam_policy" "Add_AWSCodeDeployFullAccess_policy" {
  name        = "AWSCodeDeployFullAccess"
  description = "AWSCodeDeployFullAccess"
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "codedeploy:*",
            "Effect": "Allow",
            "Resource": "*"
        },
        {
            "Sid": "CodeStarNotificationsReadWriteAccess",
            "Effect": "Allow",
            "Action": [
                "codestar-notifications:CreateNotificationRule",
                "codestar-notifications:DescribeNotificationRule",
                "codestar-notifications:UpdateNotificationRule",
                "codestar-notifications:DeleteNotificationRule",
                "codestar-notifications:Subscribe",
                "codestar-notifications:Unsubscribe"
            ],
            "Resource": "*",
            "Condition": {
                "ArnLike": {
                    "codestar-notifications:NotificationsForResource": "arn:aws:codedeploy:*:*:application:*"
                }
            }
        },
        {
            "Sid": "CodeStarNotificationsListAccess",
            "Effect": "Allow",
            "Action": [
                "codestar-notifications:ListNotificationRules",
                "codestar-notifications:ListTargets",
                "codestar-notifications:ListTagsforResource",
                "codestar-notifications:ListEventTypes"
            ],
            "Resource": "*"
        },
        {
            "Sid": "CodeStarNotificationsSNSTopicCreateAccess",
            "Effect": "Allow",
            "Action": [
                "sns:CreateTopic",
                "sns:SetTopicAttributes"
            ],
            "Resource": "arn:aws:sns:*:*:codestar-notifications*"
        },
        {
            "Sid": "CodeStarNotificationsChatbotAccess",
            "Effect": "Allow",
            "Action": [
                "chatbot:DescribeSlackChannelConfigurations"
            ],
            "Resource": "*"
        },
        {
            "Sid": "SNSTopicListAccess",
            "Effect": "Allow",
            "Action": [
                "sns:ListTopics"
            ],
            "Resource": "*"
        }
    ]
})
}

resource "aws_iam_policy" "Add_AWSCodePipeline_FullAccess_policy" {
  name        = "AWSCodePipeline_FullAccess"
  description = "AWSCodePipeline_FullAccess"
  policy = jsonencode({
    "Statement" : [
      {
        "Action" : [
          "codepipeline:*",
          "cloudformation:DescribeStacks",
          "cloudformation:ListStacks",
          "cloudformation:ListChangeSets",
          "cloudtrail:DescribeTrails",
          "codebuild:BatchGetProjects",
          "codebuild:CreateProject",
          "codebuild:ListCuratedEnvironmentImages",
          "codebuild:ListProjects",
          "codecommit:ListBranches",
          "codecommit:GetReferences",
          "codecommit:ListRepositories",
          "codedeploy:BatchGetDeploymentGroups",
          "codedeploy:ListApplications",
          "codedeploy:ListDeploymentGroups",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeSubnets",
          "ec2:DescribeVpcs",
          "ecr:DescribeRepositories",
          "ecr:ListImages",
          "ecs:ListClusters",
          "ecs:ListServices",
          "elasticbeanstalk:DescribeApplications",
          "elasticbeanstalk:DescribeEnvironments",
          "iam:ListRoles",
          "iam:GetRole",
          "lambda:ListFunctions",
          "events:ListRules",
          "events:ListTargetsByRule",
          "events:DescribeRule",
          "opsworks:DescribeApps",
          "opsworks:DescribeLayers",
          "opsworks:DescribeStacks",
          "s3:ListAllMyBuckets",
          "sns:ListTopics",
          "codestar-notifications:ListNotificationRules",
          "codestar-notifications:ListTargets",
          "codestar-notifications:ListTagsforResource",
          "codestar-notifications:ListEventTypes",
          "states:ListStateMachines"
        ],
        "Effect" : "Allow",
        "Resource" : "*",
        "Sid" : "CodePipelineAuthoringAccess"
      },
      {
        "Action" : [
          "s3:GetObject",
          "s3:ListBucket",
          "s3:GetBucketPolicy",
          "s3:GetBucketVersioning",
          "s3:GetObjectVersion",
          "s3:CreateBucket",
          "s3:PutBucketPolicy"
        ],
        "Effect" : "Allow",
        "Resource" : "arn:aws:s3::*:codepipeline-*",
        "Sid" : "CodePipelineArtifactsReadWriteAccess"
      },
      {
        "Action" : [
          "cloudtrail:PutEventSelectors",
          "cloudtrail:CreateTrail",
          "cloudtrail:GetEventSelectors",
          "cloudtrail:StartLogging"
        ],
        "Effect" : "Allow",
        "Resource" : "arn:aws:cloudtrail:*:*:trail/codepipeline-source-trail",
        "Sid" : "CodePipelineSourceTrailReadWriteAccess"
      },
      {
        "Action" : [
          "iam:PassRole"
        ],
        "Effect" : "Allow",
        "Resource" : [
          "arn:aws:iam::*:role/service-role/cwe-role-*"
        ],
        "Condition" : {
          "StringEquals" : {
            "iam:PassedToService" : [
              "events.amazonaws.com"
            ]
          }
        },
        "Sid" : "EventsIAMPassRole"
      },
      {
        "Action" : [
          "iam:PassRole"
        ],
        "Effect" : "Allow",
        "Resource" : "*",
        "Condition" : {
          "StringEquals" : {
            "iam:PassedToService" : [
              "codepipeline.amazonaws.com"
            ]
          }
        },
        "Sid" : "CodePipelineIAMPassRole"
      },
      {
        "Action" : [
          "events:PutRule",
          "events:PutTargets",
          "events:DeleteRule",
          "events:DisableRule",
          "events:RemoveTargets"
        ],
        "Effect" : "Allow",
        "Resource" : [
          "arn:aws:events:*:*:rule/codepipeline-*"
        ],
        "Sid" : "CodePipelineEventsReadWriteAccess"
      },
      {
        "Sid" : "CodeStarNotificationsReadWriteAccess",
        "Effect" : "Allow",
        "Action" : [
          "codestar-notifications:CreateNotificationRule",
          "codestar-notifications:DescribeNotificationRule",
          "codestar-notifications:UpdateNotificationRule",
          "codestar-notifications:DeleteNotificationRule",
          "codestar-notifications:Subscribe",
          "codestar-notifications:Unsubscribe"
        ],
        "Resource" : "*",
        "Condition" : {
          "StringLike" : {
            "codestar-notifications:NotificationsForResource" : "arn:aws:codepipeline:*"
          }
        }
      },
      {
        "Sid" : "CodeStarNotificationsSNSTopicCreateAccess",
        "Effect" : "Allow",
        "Action" : [
          "sns:CreateTopic",
          "sns:SetTopicAttributes"
        ],
        "Resource" : "arn:aws:sns:*:*:codestar-notifications*"
      },
      {
        "Sid" : "CodeStarNotificationsChatbotAccess",
        "Effect" : "Allow",
        "Action" : [
          "chatbot:DescribeSlackChannelConfigurations",
          "chatbot:ListMicrosoftTeamsChannelConfigurations"
        ],
        "Resource" : "*"
      }
    ],
    "Version" : "2012-10-17"
  })
}

resource "aws_iam_group_policy_attachment" "Attach_AWSCodeDeployFullAccess_policy" {
  group      = aws_iam_group.Create_group_DevOps.name
  policy_arn = aws_iam_policy.Add_AWSCodeDeployFullAccess_policy.arn
}

resource "aws_iam_group_policy_attachment" "Attach_AWSCodePipeline_FullAccess" {
  group      = aws_iam_group.Create_group_DevOps.name
  policy_arn = aws_iam_policy.Add_AWSCodePipeline_FullAccess_policy.arn
}

resource "aws_iam_group_policy_attachment" "Attach_AWSLambda_FullAccess_policy_to_DevOps" {
  group      = aws_iam_group.Create_group_DevOps.name
  policy_arn = aws_iam_policy.Add_AWSLambda_FullAccess_policy.arn
}

# Users
