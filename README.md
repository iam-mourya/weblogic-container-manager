Automate WebLogic in Docker Containers
This script simplifies the automation of Oracle WebLogic setup in Docker containers, aiming to streamline containerization for development and production environments. It covers tasks such as:

Configuring WebLogic credentials
Installing essential packages and dependencies
Managing NodeManager and AdminServer processes
Checking the status of WebLogic containers
By automating these steps, the script helps improve deployment efficiency and consistency when running WebLogic in Docker containers.

For more details, refer to the  "https://devopsswift.blogspot.com/2025/01/automate-weblogic-in-docker-containers.html" blog post.

![image](https://github.com/user-attachments/assets/cf1eec7b-a8c1-4409-bcc7-f580f1a419f4)

Inputs:
=========
WebLogic Docker Image: The Oracle WebLogic image used (e.g., container-registry.oracle.com/middleware/weblogic:12.2.1.4).
Properties File:
Path: /home/ubuntu/domain.properties
Contains admin credentials (admin-username, admin-password).
Automatically created if not found.
Config.xml: The WebLogic domain configuration file inside the container (/u01/oracle/user_projects/domains/base_domain/config/config.xml).

Requirements:
=============
Docker: Installed and running on the host machine.
Oracle WebLogic Docker Image: Pulled and available locally or from the Oracle Container Registry.
Permissions: Script should run with privileges to execute Docker commands.

Utilities:
==========
procps and net-tools are installed within the container by the script.
Ports: The following ports must be available on the host system:
7001 (Admin Console)
7004 Customise this as per your requirement we have defined here assuming we will be assigning it to managed server
5556 (Node Manager)

Features:
=========
Automatically creates a properties file for admin credentials if missing.
Ensures previous containers with the same name are removed before launching a new one.
Configures the container with mounted domain properties and necessary ports.
Installs required tools (procps, net-tools) in the container.
Modifies config.xml to disable administration ports.

Sets up and starts:
===================
NodeManager
AdminServer
Restarts the AdminServer to apply any updates.

Outputs:
========
Docker container status.
Running processes within the container.
