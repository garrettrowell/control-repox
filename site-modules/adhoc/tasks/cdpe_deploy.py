#!/usr/bin/env python
import os, sys, requests, json
sys.path.append(os.path.join(os.path.dirname(__file__), '..', '..', 'python_task_helper', 'files'))
from task_helper import TaskHelper

class MyTask(TaskHelper):
  def task(self, args):
    # supress verify=False warning... friends don't let friends do this in production :)
    requests.packages.urllib3.disable_warnings()

    # Auth headers for CD4PE
    deploy_headers = {
      'content-type': 'application/json',
      'Authorization': args['cd4pe_api_token']
    }
    # POST data to trigger a pipeline at a given stage
    deploy_data = {
      'projectID': {
        'domain': args['project_domain'],
        'name': args['project_name']
      },
      'sha': args['sha'],
      'stageNumber': args['stage_number'],
      'commitMessage': args['commit_message']
    }
    # URL to trigger pipeline deployment
    deploy_url = 'https://{endpoint}/cd4pe/api/v1/pipelines/{pipeline_id}/trigger'.format(endpoint=args['cd4pe_endpoint'], pipeline_id=args['pipeline_id'])
    # Make the POST call
    deployment_request = requests.post(deploy_url, headers=deploy_headers, json=deploy_data, verify=False)
    if deployment_request.status_code == 204:
      return { 'result': 'Deployment for {project} at {stage} successful'.format(project=args['project_name'], stage=args['stage_number']) }
    else:
      try:
        err_msg = deployment_request.json()
        return { 'result': err_msg }
      except:
        return { 'result': 'deployment request returned '+str(deployment_request.status_code) }

if __name__ == '__main__':
    MyTask().run()
