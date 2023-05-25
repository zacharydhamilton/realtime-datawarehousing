# <div align="center">Real-time Data Warehouse Ingestion with Confluent Cloud</div>
## <div align="center">Workshop & Lab Guide</div>

## Prerequisites

The imply workshop should be done once you have gone through the Confluent Cloud Real-time Data Warehouse Ingestion guide. Once you have a topic provisioned within your Confluent Cloud cluster, you can ingest data from the topic into your Imply Polaris Environment.

## Prerequisites

- Imply Polaris Sign-Up Here: https://signup.imply.io/get-started
- Confluent Cloud Topic Name
- Confluent Cloud Bootstrap Server
- Confluent Cloud API Key
- Confluent Cloud API Secret

## Step-by-Step

### Create Polaris Account

If you don't already have a Polaris account, sign up for a limited trial:

1. Go to https://signup.imply.io.

2. Enter your information in the sign-up form.Your organization name must meet the following criteria:

	- It must contain a minimum of 3 and a maximum of 63 characters. Characters are letters, numbers, and dashes.
	- It must begin with a letter or a number and end with a letter or a number.
	- It cannot start or end with a dash.
	- It cannot contain symbols such as asterisks, underscores, and exclamation points.
	- It cannot end with -imply-cloud.

3. Click Sign up.

4. Check your inbox for a confirmation email from Imply. You must verify your email address to create an account. If you do not receive a confirmation email or have trouble signing up, please contact [Polaris Support](https://polaris-support.imply.io/hc/en-us).

After you've verified your email address, you should receive a welcome email from Imply containing a link to your Polaris account. Click on the link in the email to access your account.

At first login, you are prompted to choose a cloud region in which Imply will host your project.

Polaris supports the following regions:

- us-east-1: US East (N. Virginia)
- us-west-2: US West (Oregon)
- eu-central-1: Europe (Frankfurt)
- eu-west-1: Europe (Ireland)
- Polaris can only host a single project for you in each region.

### Load Data

Once you have logged into your Polaris Environment, click on the ```Sources``` tab. 

Click on ```New Source```. And then click on the Confluent Cloud icon. 

Here specify a connection name(Required), a description(Optional), the name of the topic you created earlier using the realtime-datawarehousing guide(required), the bootstrap server for your Confluent Cloud Cluster(required), and your Confluent Cloud API key and Confluent Cloud API Secret key(required). 

Click on Test Connection. If the result is ```Success!``` click create connection and you have successfully connected your Confluent Cloud topic to your Polaris account. 

### Create Table 

To create a table, follow these steps:

1. Click Tables in the left pane.
2. Click Create table in the top-right corner.
3. Enter ```Confluent Cloud Table``` for the table name. 
This quickstart doesn't use aggregations, so leave the Table type as Detail. See [Types of tables](https://docs.imply.io/polaris/tables/#types-of-tables) to learn more.
Click Create.

### Upload a file and view sample data

1. On the table detail page, click Load data > Insert data.

2. Go to The Streaming Section, and Click on Confluent Cloud. 

3. Here you will see your Confluent Cloud connection ready to go. Click on the connection you had created earlier, and click next. 

4. Click on the Input Format tab, and scroll to Avro. Here you will see two options, Option 1: Use Inline, and Option 2: Use schema in registry. 

5. Click on Option 2: Use schema in registry. Input your schema registry URL and info here, click Test Connection, and if everything looks good, press Continue. 

6. You will see a preview of your data. Here you are free to manage your inputs, add fields, remove fields, etc. If everything looks good, go ahead and start the ingestion. 


### Query Data

1. Go back to the Tables tab. 

2. Here you should see the table you have just created. Click on the table. 

3. On the top right, You will see a Query tab. Click on the Query tab, and click on ```Create Data Cube```.

### Pivot

In Imply Pivot, you are provided an interface where you can play with your data, create visualizations, and create dashboards.

Lets create a simple events over time visualization and add it to a dashboard. 

1. At the Filter section, change the time frame from Latest 1 hour, to Last 1 day.
2. On the left side, you will see a dimensions tab. Drag the ```__time``` dimension to the Show section. 
3. You should see a time graph with data points specifying data ingested over time. 
4. On the top right you will see a logo with 3 cubes and a plus sign. This logo is the ```Add to Dashboard``` tab. Click on it, then click on ```Create New Dashboard```. 
5. You can drag the new visualization you created and edit how small or large you want it. Click on the ```Create``` tab on the top right. 
6. Congratulations! You have created your first dashboard!  

