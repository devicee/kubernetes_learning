# README
This document will guide you through the setup of a web application with kubernetes. The emphasis is on the kubernetes itself rather than a simple Django app. Once it is accessible via the domain, unencrypted HTTP, we will continue to set up the TLS certificate for secure HTTPS.
![Diagram](https://raw.githubusercontent.com/devicee/kubernetes_learning/master/images/kubernetes_cluster_in_this_tutorial.png)
## Description of the diagram and 

## Deploying your application in Kubernetes
1. First build the image with the following command, change your docker path:
``docker build --tag refikh/django_refa:latest .``
2. Then try to run it locally with the following command:
``docker run --name django_refa -d -e TEST_VAR='SOMETHING' -p 8000:8000 refikh/django_refa:latest``
3. Then test it in your browser: `localhost:8000`
4. Login to docker: `docker login` and enter your username and password
5. Push it to Docker Hub with the following command:
``docker push refikh/django_refa:latest``
6. Change the kubernetes config file so that you have access to your kubernetes online (in my case digital ocean), it is located in ~/.kube/config
7. Set the config variables in kubernetes by running: 
``kubectl apply -f k8s/config_map_env_var.yaml``
8. Set the secret variables in kubernetes by running: 
``kubectl apply -f k8s/secret.yaml``
9. Once it is pushed, you can start kubernetes deployment:
``kubectl apply -f k8s/deployment.yaml``
10. Then see if it was successfully deployed:
``kubectl get deployments`` or to see if pods are running
``kubectl get pods``
11. To see if everything is ok: 
``kubectl describe deployment example-deploy`` this 'example-deployment' is the name of the deployment.
12. To deploy the service:
``kubectl apply -f k8s/service.yaml``
13. OPTIONAL: if you are on minikube in localhost, you can run the following command to get the IP of the service:
``sudo minikube tunnel``
14. With HELM package manager add the ingress nginx controller. ``helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx``
15. Update the repos ``helm repo update``
16. Install the nginx ingress controller ``helm install nginx-ingress ingress-nginx/ingress-nginx --set controller.publishService.enabled=true``
17. Repeat ``kubectl get svc `` until you see an IP address in EXTERNAL-IP. 
18. Then in your domain settings, apply an A record, for your subdomain "www", to that loadbalancer IP called ``nginx-ingress-ingress-nginx-controller``. Wait for TTL at least 30 seconds, and set it in the domain setting. Wait some time. In ingress.yml set your domain, change your service name.
19. Check on your machine the DNS is refreshed and links to the above IP address by typing: ``nslookup www.lab4iottest.xyz``
20. Then apply the ingress configuration ``kubectl apply -f k8s/ingress.yaml``, wait till you can open the Django site on the given domain via http protocol! 

## Setting up the TLS certificate
1. Build the namespace for the TLS certificate manager ``kubectl create namespace cert-manager``
2. Add to the HELM package manager the certificate-manager ``helm repo add jetstack https://charts.jetstack.io``
3. Update HELP ``helm repo update``
4. Install the certificate-manager in above namespace ``helm install cert-manager jetstack/cert-manager --namespace cert-manager --version v1.2.0 --set installCRDs=true``
5. Modify the email in the k8s/production_issuer.yaml file. Then apply it: ``kubectl apply -f production_issuer.yaml``
6. Once installed, please copy ingress.yaml to another file ingress_ssl.yaml.
7. Modify your `hosts` and `cert-manager.io/cluster-issuer`, in the file ingress_ssl.yaml to the one given in production_issuer.yaml: letsencrypt-prod
8. Then apply the changes: ``kubectl apply -f k8s/ingress_ssl.yaml``
9. Wait a minute or two, so Letsencrypt issues you the certificate, to check if the certificate was issued, type: ``kubectl describe certificate hello-kubernetes-tls``
10. If the certificate was issued, in the output you will see:
```
  Normal  Issuing    59s   cert-manager  Issuing certificate as Secret does not exist
  Normal  Generated  59s   cert-manager  Stored new private key in temporary Secret resource "hello-kubernetes-tls-thm7d"
  Normal  Requested  59s   cert-manager  Created new CertificateRequest resource "hello-kubernetes-tls-6t5vt"
  Normal  Issuing    32s   cert-manager  The certificate has been successfully issue
```
11. That's it! You are done, you can access your site via the HTTPS endpoint.

## Guideline and references to help you understand Kubernetes better and more
1. Kuberenetes for beginners:
https://www.youtube.com/watch?v=8h4FoWK7tIA&list=PLHq1uqvAteVvUEdqaBeMK2awVThNujwMd

2. TLS Certificate and nginx ingress controller for DigitalOcean
https://www.digitalocean.com/community/tutorials/how-to-set-up-an-nginx-ingress-on-digitalocean-kubernetes-using-helm