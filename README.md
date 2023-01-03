AWS Configuration

As I wanted to use the free resources as much as possible, I decided to use an autoscaling group with t2.micro instances. The instances were deployed inside a public subnet, that only had the ports 3000 (the one used by the application) and 22 open, but only to be accessed by the load balancer of other resources inisde the VPC, all deployed by a Jenkins server. 

<img width="926" alt="Screen Shot 2023-01-02 at 18 48 03" src="https://user-images.githubusercontent.com/111317556/210287945-a3035590-3133-4a75-836b-3e6f99e0ee06.png">

The best design would be to use a Redis inside Elasticache so as to share the same data among all nodes. Furthemore, I did not put any server in multiple az as the instance type that I am using does not support multiple network interface cards. All of the infrastructure was deployed using a Jenkins pipeline:

<img width="1382" alt="Screen Shot 2023-01-02 at 19 13 21" src="https://user-images.githubusercontent.com/111317556/210288929-296b313e-79e0-4554-911a-e64aa5be188d.png">

Some exampled of the infrastructure created on AWS would be the following ones:

<img width="1382" alt="Screen Shot 2023-01-02 at 19 13 21" src="https://user-images.githubusercontent.com/111317556/210288929-296b313e-79e0-4554-911a-e64aa5be188d.png">



As I designed everything based on the free resources provided by AWS, the best appraoch would be the following one:
