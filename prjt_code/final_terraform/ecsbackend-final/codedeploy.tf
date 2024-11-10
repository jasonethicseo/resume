resource "aws_codedeploy_app" "ecs_app_2" {
  name             = "codedeploy-back-app-970728"
  compute_platform = "ECS"
}

resource "aws_codedeploy_deployment_group" "ecs_deployment_group_2" {
  app_name               = aws_codedeploy_app.ecs_app_2.name
  deployment_group_name  = "codedeploy-back-group-970728"
  service_role_arn       = "arn:aws:iam::971422701599:role/970728-codedeploy" #계정 전환시 바꿔야됨

  deployment_config_name = "CodeDeployDefault.ECSAllAtOnce"  # 이 부분을 추가합니다

  ecs_service {
    cluster_name = "ecs-cluster-970728"
    service_name = "ecs-prjt-back-service-970728"
  }

  load_balancer_info {
    target_group_pair_info {
      
      target_group {
        name = "TG-ECS-BACK-970728"
      }
      target_group {
        name = "TG-ECS-BACK-NEW-970728"
      }


      prod_traffic_route {
        listener_arns = [aws_lb_listener.back_listener.arn]
      }
    }
  }

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }

  blue_green_deployment_config {

    deployment_ready_option {
      action_on_timeout = "CONTINUE_DEPLOYMENT"
      wait_time_in_minutes = 0
    }

    terminate_blue_instances_on_deployment_success {
      action = "TERMINATE"
      termination_wait_time_in_minutes = 5
    }
  }

  depends_on = [
    aws_ecs_service.ecs_prjt_back_service,
    aws_ecs_cluster.ecs_cluster
  ]
}
