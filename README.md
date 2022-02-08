## Deploy Python Application using AWS App Runner
###### by Sathish Kumar Prabakaran, Enterprise Solution Architect, Global Enterprise

It takes a village to design, develop, and host an application. It all starts with a business use case that gets translated to requirements and design and is then handed over to the developers for development. The developers create the application, test it in their local environments, and hand it over to the operations team for hosting. There are often delays in provisioning the infrastructure and hosting the application. Until now, it has been a dream of the business stakeholders and developers to see their use case application creating a positive impact on their end customers immediately after development.   

AWS App Runner comes to the rescue and helps developers publish their apps quickly. AWS App Runner is a fully managed service that makes it easy for developers to quickly deploy containerized web applications and APIs at scale and with no prior infrastructure experience. Developers just point their source code or a container image to AWS App Runner, and AWS App Runner automatically builds and deploys the web application and load balances traffic securely. App Runner also scales up or down automatically to meet your traffic needs. It takes the undifferentiated heavy lifting of provisioning servers, scaling them based on the demand, and load balancing the requests, which allows you to focus your valuable time on creating features that enhance your customers' experience instead of managing the infrastructure.

In this blog, we will deploy a containerized Python application that interacts with Amazon DynamoDB using AWS App Runner. 
 

## Overview of solution 

The solution will set up a CodePipeline that pulls the code from GitHub and builds the codes, then stores the container image artifact in Amazon ECR. App Runner is configured to trigger automatic deployments once a new image is pushed to ECR. Python applications running in App Runner will leverage Amazon DynamoDB as the persistent data store and stream the log to Amazon CloudWatch. 

![](/Images/Architecture.png)

## Walkthrough

### Prerequisites:

For this walkthrough, you should have the following prerequisites: 
- An AWS account with full privileges to create the following resources: 
	* S3 Bucket
	* IAM Role 
	* CodePipeline 
	* CodeBuild
	* DynamoDB Table 
	* ECR Repository
	* APP Runner 
- Basic knowledge of containers

### Step-by-step instructions to implement the above solution is as follows:
#### •   Step 1: Fork the repository to your GitHub account.

#### •	Step 2: Clone the forked repository to your AWS CloudShell console and navigate to the cloned directory.

#### •	Step 3: Launch the CloudFormation stack to create the pipeline that gets invoked when a code is committed. You will have to provide the following input parameters: 

[Launch stack button]

- BranchName: GitHub Branch Name
- RepositoryName: GitHub Repository Name
- ECRRepoName: ECR Repository Name 
- GitHubOAuthToken: GitHub OAuth Token to authenticate and pull the source code 
- RepoOwner: GitHub Owner Name (User Name) 

#### •	Step 4: Load test data to DynamoDB table 
1.	Navigate the cloned repository directory. 
2.	Execute the below script to load the test data.
```
bash scripts/LoadData.sh
```

#### •	Step 5: Now, let’s set up the IAM roles required for App Runner. App Runner uses the IAM role to interact with other AWS services. 
1.	Navigate the cloned repository directory. 
2.	Create an IAM role called App-Runner-ServiceRole.
```
aws iam create-role --role-name App-Runner-ServiceRole --assume-role-policy-document file://apprunner-role.json
```
3.	Now attach the policies that allow App Runner to integrate with DynamoDB and CloudWatch
```	
aws iam attach-role-policy --policy-arn arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess --role-name App-Runner-ServiceRole
aws iam attach-role-policy --policy-arn arn:aws:iam::aws:policy/CloudWatchLogsFullAccess --role-name App-Runner-ServiceRole
```

#### •	Step 6: Now, Let’s set up the App Runner service
1.	Sign in to the AWS console.
2.	Navigate to the AWS App Runner service page.
3.	Choose Create an App Runner Service.
4.	Select repository type as Container Registry.
5.	Select provider as Amazon ECR.
6.	Choose Browse to select your ECR repository and set the Image tag to latest.

![](/Images/ECR_Repo_Selection.png)

7.	Choose Continue.	 

![](/Images/Source_Final.png)

8.	Navigate to the Deployment settings section 
9.	Set the Deployment trigger to Automatic 
10.	Select Create new service role for the ECR access role. 

![](/Images/Deployment_Settings.png)

11.	Choose Next.
12.	In the Service settings section, provide a Service name python-app.
13.	Set the Virtual CPU as 1vCPU and 2 GB memory. 
14.	Click on Add environment variable and add the following two environment variables:

| Key | Value |
| --- | --- |
| AWS_REGION | AWS Region ID (Eg: us-east-1 ) |
| DDB_TABLE | Movies |

  
15.	Port should be 8080.
16.	Ignore the Additional configuration. 
		
![](/Images/Service_Settings.png)

17.	No changes are required on the Autoscaling and Health check section. Navigate to the Security section. 
18.	In the Security section, attach the instance role that was created earlier AppRunner-ServiceRole
19.	Select Use an AWS-owned key in the AWS KMS key section 

![](/Images/Security.png)
		 
20.	Choose Next. 
21.	Review all the configurations and choose Create & deploy. 
22.	Monitor the Service overview section and monitor the Status. The service is ready when the status turns to Running.

![](/Images/Service_Overview.png)

23.	Now click on the default domain URL to access your service. 

![](/Images/URL_Access.png)

		 
#### •	Step 6: Follow the API documentation and test the GET, POST, PUT, and DELETE APIs. 
##### 1.	GET

To test the GET method, copy the App Runner Default domain and add the path /api/movie and pass a value to the query arguments “year” and “title.” You can use a standard browser like Firefox or Chrome to test the GET method. 

![](/Images/GET.png)

		 
##### 2.	POST
To test the POST method, you will have to use a tool like Postman or curl. If you plan to use curl, it is important to add the correct content-type HTTP header. Copy the App Runner Default domain and add the path /api/movie. The request body should follow the following JSON schema:
```
{
	“year” : integer,
	“title” : “string”,
	“info”: {
	“plot” : “string”,
	“rating”: integer,
	“rank” : integer,
	“running_time_secs”: integer
	}
}
```
![](/Images/POST.png)

The following shows an example curl command using the information in the screenshot:

```
curl -v -X POST -H "Content-Type: application/json"  -k -i 'https://<your-endpoint>/api/movie' --data '{ "year": 1944, "title": "King Kong 2", "info": { "plot" : "King Kong Sequel Part 2", "rating": 5, "rank": 100, "running_time_secs": 5821 } }'
```
##### 3.	DELETE
To test the DELETE method, copy the App Runner Default domain and add the path /api/movie and pass a value to the query arguments “year” and “title.” Use tools like Postman or curl to send a DELETE request to the endpoint. 

![](/Images/DELETE.png)

The following shows an example curl command using the information in the screenshot:

```
curl -X DELETE https://<your-endpoint>/api/movie?year=1944&title=King%20Kong%202
```
Cleaning up:
- Delete the App Runner service
- Delete the IAM role created earlier App-Runner-ServiceRole.
- Delete the CloudFormation stack. 



## Conclusion: 
The blog covered how an application can be deployed without any infrastructure knowledge by the developers themselves, in turn reducing the time to market and increasing agility. 

The AWS App Runner developer guide is available at the following link: https://docs.aws.amazon.com/apprunner/latest/dg/what-is-apprunner.html

AWS App Runner’s roadmap is publicly accessible at https://github.com/aws/apprunner-roadmap/projects/1. Feel free to review the roadmap items and vote for the ones that you would like us to prioritize.

## License

This library is licensed under the MIT-0 License. See the LICENSE file.

