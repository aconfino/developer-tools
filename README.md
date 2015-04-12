### Setup
The RHEL EC2 instance doesn't have git by default.  The following commands bootstrap your project.
* sudo yum -y install git
* git clone https://github.com/aconfino/developer-tools.git
* copy bootstrap.sh into your home directory
* modify the bootstrap.sh file to call papply.sh with the tool you wish to stand up