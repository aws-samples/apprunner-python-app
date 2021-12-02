
Deploy Python Application using AWS App Runner
by Sathish Kumar Prabakaran, Enterprise Solution Architect, Global Enterprise

It takes a village to design, develop and host an application. It all starts with a business use case that gets translated to requirements, design, and handed over to the developers for development. The developers create the application and test it in their local environments and handover to operations team for hosting the same and there is often delays in provisioning the infrastructure and hosting the application. Till now it has been a dream to the business stakeholders and developers to see their use case/application creating a positive impact to their end customers immediately after development.   

AWS App Runner comes to rescue and helps developers to publish their apps quickly. AWS App Runner is a fully managed service that makes it easy for developers to quickly deploy containerized web applications and APIs, at scale and with no prior infrastructure experience. Developers just point their source code or a container Image to AWS App Runner and AWS App Runner automatically builds and deploys the web application and load balances traffic securely. App Runner also scales up or down automatically to meet your traffic needs. It takes the undifferentiated heavy lifting of provisioning servers, scaling them based on the demand and load balancing the requests which allows you to focus your valuable time on creating features that enhance your customers experience instead of managing the infrastructure.

In this blog, we will deploy a containerized Python application that interacts with Amazon DynamoDB. The high level architecture is as follows 

## Solution architecture and design


## ![](/Images/Architecture.png)

 
The following are the step-by-step instructions to setup the above architecture.

•	Let’s setup the DynamoDB Database by following the document Link and load test data to the database following the document Link.

•	Fork the repository to your GitHub Account.
•	Clone the forked repository to your IDE Environment and Navigate to the cloned directory

•	Launch the CloudFormation stack to create the Pipeline that gets invoked when a code is committed. The Code Build process creates a container image and stores the artifact in ECR. You will have to provide the following Input parameters 

		o	BranchName: GitHub Branch Name
		o	RepositoryName: GitHub Repository Name
		o	ECRRepoName: ECR Repository Name 
		o	GitHubOAuthToken: GitHub OAuth Token to authenticate and pull the source code. 
		o	RepoOwner: GitHub Owner Name (User Name) 

•	Now let’s setup the IAM Roles required for App Runner. App Runner uses the IAM role to interact with other AWS Services. 
		o	Navigate the cloned repository directory 
		o	Create an IAM Role called App-Runner-ServiceRole 

				aws iam create-role --role-name App-Runner-ServiceRole --assume-role-policy-document file://apprunner-role.json

		o	Now attach the Policies that allow App Runner to integrate with DynamoDB and CloudWatch


				aws iam attach-role-policy --policy-arn arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess --role-name App-Runner-ServiceRole

				aws iam attach-role-policy --policy-arn arn:aws:iam::aws:policy/CloudWatchLogsFullAccess --role-name App-Runner-ServiceRole


•	Now Let’s setup the App Runner Service

		o	Login to AWS Console
		o	Navigate to AWS App Runner Service Page
		o	Click on “Create an App Runner Service”
		o	Select Repository type as “Container Registry”
		o	Provider as “Amazon ECR”
		o	Click on Browse to select your ECR Repository and set the Image tag to “Latest”

## Select Amazon ECR Container Image


## ![](/Images/ECR_Repo_Selection.png)
		 

		o	Click “Continue”

## Source


## ![](/Images/Source_Final.png)

       		o	Move to “Deployment Settings” Section 
		o	Set the Deployment trigger to Automation 
		o	Select “Create new service role” for ECR access role. 

## Deployment Settings

## ![](/Images/Deployment_Settings.png)

		o	Click Next
		o	In the Service Settings section, provide a service name “Python-app”
		o	Set the Virtual CPU as 1vCPU and 2 GB Memory 
		o	Click on Add Environment Variable and add the following two environment Variables 
				Key	        Value
				AWS_REGION	AWS Region ID (Eg: us-east-1 ) 
				DDB_TABLE	Movies
  
		o	Port should be 8080
		o	Ignore the Additional Configuration  
		
## Service Settings

## ![](/Images/Service_Settings.png)
		o	No changes are required on the Autoscaling and Health check section, navigate to Security section 
		o	In the Security section, Attach the instance role which was created earlier App-Runner-ServiceRole
		o	Select “Use an AWS-Owned Key” in the AWS KMS Key section 
		
## Security Settings

## ![](/Images/Security.png)
		 
		o	Click Next 
		o	Review all the configuration and click on Create & deploy. 
		o	Monitor the Service Overview section and monitor the status. The Service is ready when the Status turns to “Running”
		
## Service Status

## ![](/Images/Service_Overview.png)

		o	Now click on the default domain URL to access your service. 
## URL

## ![](/Images/URL_Access.png)

		 
		o	Follow the API Documentation and test the GET, POST , PUT and DELETE API’s. 
		o	GET
			To test the GET method copy the App Runner Default Domain and add the path /api/movie and pass a value to the query arguments “year” and “title”. You can use a standard browser like Firefox, Chrome to test the GET method. 
## GET

## ![](/Images/GET.png)

		 
		o	POST
			To test the POST method you will have to use a tool like Postman. Copy the App Runner Default Domain and add the path /api/movie. The Request body should follow the following JSON schema 

				{
				“year” : “Integer”,
				“title” : “string”,
				“info”: {
				“plot” : “string”,
				“rating”: integer,
				“rank” : integer,
				“running_time_secs”: integer
				}
				}
## POST

## ![](/Images/POST.png)


		o	DELETE
			To test the DELETE method copy the App Runner Default Domain and add the path /api/movie and pass a value to the query arguments “year” and “title”. Use tools like Postman to send a DELETE request to the endpoint. 
## DELETE 

## ![](/Images/DELETE.png)

Clean-up Steps:
o	Delete the App Runner Service 
o	Delete the IAM Role created earlier App-Runner-ServiceRole
o	Delete the CloudFormation Stack 


Conclusion: 
The blog covered how an application can be deployed without any infrastructure knowledge by the developers themselves in-turn reducing the time to the market and increasing the agility. 

App Runner developer guide is available in the following link.  https://docs.aws.amazon.com/apprunner/latest/dg/what-is-apprunner.html

App Runner’s roadmap is publicly accessible https://github.com/aws/apprunner-roadmap/projects/1 feel free to review the roadmap items and vote for the roadmap items that you would like us to prioritize. 


## License

This library is licensed under the MIT-0 License. See the LICENSE file.

