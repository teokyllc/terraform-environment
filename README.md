# The Terraform Stack

This is a Terraform environment project for a single AWS account.  Snake casing is the standard for Terraform variables and resource naming.<br>

![The Terraform Stack](stack.jpg?raw=true 'The Terraform Stack')<br>

## What does Terraform do?

Terraform evaluates a set of Terraform configuration to determine the desired state of all the resources it declares, then compares that desired state to the real infrastructure objects being managed with the current working directory. It uses state data to determine which real objects correspond to which declared resources, and checks the current state of each resource using the relevant infrastructure provider's API. Once it has determined the difference between the current state and the desired state, terraform plans presents a description of the changes necessary to achieve the desired state. Terraform applies actually carries out the planned changes to each resource using the relevant infrastructure provider's API.

## What is a Terraform stack?

A stack in the context of a Terraform project is the collection of layers which make up the infrastructure. These are an arbitrary number of logical layers that it makes sense to divide the infrastructure into. The layers of the stack are the subfolders in this directory. In each of these folders are Terraform configuration files which create resources relating to the layer.

## What is a Terraform environment?

An environment is a named stack. If we take this set of Terraform configurations to create a stack and pass in different sets on input arguements, then we will end up what we are calling an environments. Think about this as in dev, test, staging, and prod. All similar in the resources that make up the stack, but different inputs. In each layer subfolder you will see another folder called envs. This folder holds .tfvars files, these are the values to all the variables for this layer of the stack.

## Why is there a Kubernetes and Kubernetes-CRD layer?

# Remote State

When working with Terraform in a team, use of a local state files makes Terraform usage complicated because each user that run Terraform creates state locally. With remote state, Terraform writes the state data to a remote data store, which can then be shared between all members of a team.
<br><br>
Remote state is implemented by a backend in a file named provider.tf. Each layer of the stack will have a state file. Values and data structures can be shared between state files with outputs and [remote_state]() data sources.
Remote state is implemented by a backend in a file named provider.tf. Each layer of the stack will have a state file. Values and data structures can be shared between state files with outputs and [remote_state](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/data-sources/remote_state) data sources.<br><br>

# Terraform Modules

A module is a grouping of usually more than one similar resources that are used together to create building blocks of reusable infrastructure. Modules can be thought of like a class or function, its the implmentation of a certain unit of infrastructure. The actual infrastructure would be combinations of different parameters passed into the modules. This creates a seperation of the logic creating infrastructure, and the configuration defining the outcome. This repo is just the values/parameters side using modules that already exist.

# Terraform Releases

-   Create a branch - Branch protection policies will prevent you from directly pushing to main.

-   Commit changed environment configurations. On a push to any branch Actions runs a Terraform plan so you can see if the Terraform syntax is valid or not.

-   Submit a PR - The merge option will be blocked with protection policies. One of which is the Terraform must be sucessfully deployed to the testing environment. Another is all conversations on code must be resolved, require status checks to pass, and require branches to be up to date before merging. When all conditions are met and the deployment to test environment is sucessfull the pull request can be merged.

-   Merge the PR - Take caution around the timing of the merge because once merged, Actions will run the Terraform changes against the production Terraform stack. Depending on the nature of the change, there could be potential downtimes. The exercise of running the exact change (the code in the PR) against the testing environment is to give you understanding on how this chnage is going to effect production once you merge it.