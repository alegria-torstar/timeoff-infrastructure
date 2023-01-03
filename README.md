AWS Configuration

As I wanted to use the free resources as much as possible, I decided to use an autoscaling group with t2.micro instances. The instances were deployed inside two different public subnets, each in different az. Each instance only has the ports 3000 (the one used by the application), which can only be accessed by the load balancer and 22 open, with the last one could only accessed by any resource inside the same VPC. I decided to deploy the instances inisde the public subnets so as to avoid any economical cost of using a NAT Gateway.

<img width="816" alt="Screen Shot 2023-01-02 at 20 31 24" src="https://user-images.githubusercontent.com/111317556/210293184-3a9e7a35-f892-4dc8-be47-04a0137a610f.png">

The best design would be to use a Redis inside Elasticache so as to share the same data among all nodes. Furthemore, all of the infrastructure was deployed using a Jenkins pipeline:

<img width="1382" alt="Screen Shot 2023-01-02 at 19 13 21" src="https://user-images.githubusercontent.com/111317556/210288929-296b313e-79e0-4554-911a-e64aa5be188d.png">

Some examples of the infrastructure created on AWS would be the following ones:

<img width="1473" alt="Screen Shot 2023-01-02 at 19 16 09" src="https://user-images.githubusercontent.com/111317556/210289062-fd4c513d-1416-4f9a-a7ae-dfaa84cd81cd.png">

<img width="1485" alt="Screen Shot 2023-01-02 at 19 15 21" src="https://user-images.githubusercontent.com/111317556/210289110-5cddeec9-a537-4268-92a4-89450f13fca6.png">

<img width="1415" alt="Screen Shot 2023-01-02 at 19 18 55" src="https://user-images.githubusercontent.com/111317556/210289205-b23c54c6-c263-4ef0-acc2-be0ac80b76dd.png">

The application can be accessed using the folling dns: http://timeoff-alb-716649619.us-east-1.elb.amazonaws.com/login/

As I designed everything based on the free resources provided by AWS, the best appraoch would be the following one:


