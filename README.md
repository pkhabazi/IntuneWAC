# Build Status

[![Build Status](https://dev.azure.com/pkm-technology/IntuneWAC/_apis/build/status/pkhabazi.intune?branchName=master)](https://dev.azure.com/pkm-technology/IntuneWAC/_build/latest?definitionId=52&branchName=master)

# Microsoft Intune

Microsoft Intune is a cloud-based service in the enterprise mobility management (EMM) space that helps enable your workforce to be productive while keeping your corporate data protected. Similar to other Azure services, Microsoft Intune is available in the Azure portal. With Intune, you can:

* Manage the mobile devices and PCs your workforce uses to access company data.
* Manage the mobile apps your workforce uses.
* Protect your company information by helping to control the way your workforce accesses and shares it.
* Ensure devices and apps are compliant with company security requirements.

 [read more](https://docs.microsoft.com/en-us/intune/what-is-intune)

## Microsoft Graph for Intune

The Microsoft Graph API for Intune enables programmatic access to Intune information for your tenant; the API performs the same Intune operations as those available through the Azure Portal.

For mobile device management (MDM) scenarios, the Microsoft Graph API for Intune supports standalone deployments; Intune [hybrid deployments](https://docs.microsoft.com/en-us/sccm/mdm/understand/choose-between-standalone-intune-and-hybrid-mobile-device-management) are not supported.

## PowerShell Module

This PowerShell module is created to implement a Workspace As Code (WAC) principe, which means:

> WAC is the process of managing and provisioning end user workspace through machine-readable definition files, rather than interactive configuration tools.

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes. See deployment for notes on how to deploy the project on a live system.

### Prerequisities

* nothing for now

### Installing

A step by step Guid how to install module

```PowerShell
Install-Module .\PSIntuneWAC -Force
```

### Usage

#### Parameters

List the different parameters available

## Running the tests

Explain how to run the automated tests for this system

### Break down into end to end tests

Explain what these tests test and why

```
Give an example
```

### And coding style tests

Explain what these tests test and why

```
Give an example
```

## Find us

* [GitHub](https://github.com/pkhabazi/intune)
* [Blog PKM](https://pkm-technology.com)
* [Blog TalkingWorkplace](https://talkingworkplace.com)

## Contributing

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct, and the process for submitting pull requests to us.

## Versioning

We use [SemVer](http://semver.org/) for versioning. For the versions available, see the [tags on this repository](https://github.com/pkhabazi/intune/tags).

## Authors

* **Pouyan Khabazi** - *Initial work* - [GitHub](https://github.com/pkhabazi)
* **Frans Oudendorp** - *Initial work* - [GitHub](https://github.com/foudendorp)

See also the list of [contributors](https://github.com/pkhabazi/intune/contributors) who participated in this project.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details

## Acknowledgments

* This PS module is based on initial code and ideas of [Ben Reader](https://github.com/tabs-not-spaces)
* Hat tip to anyone whose code was used
* Inspiration
