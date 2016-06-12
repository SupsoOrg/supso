README FOR SUPPORTED SOURCE PROJECT DIRECTORY
---------------------------------------------

1. What is this directory?

This directory contains information connecting your user or organization with Supported Source projects you use. If you've never heard of Supported Source, it's probably being included from a project you're using.


2. Should I check this into version control?

Yes, you should check this directory into your version control. The files are needed in order for the projects to run properly.


3. What is Supported Source?

Supported Source is a platform for projects to learn who their users are. You can learn more about this at supportedsource.org


4. How's it work?

A project that includes Supported Source will ask the developers to run `supso update` in order to get a token associated with their use of the project. The first time you run supso update, you also have to provide your email address.

A confirmation token is sent to the email address. After confirming you are who you say you are, the `supso update` command will store client tokens for each project in this directory. These client tokens are used to verify the process completion.


5. Does everyone on my team need to get a Supported Source account?

No, only one person needs to. You'll just need to get the project's client tokens by running `supso update` then check this directory into your version control. It doesn't hurt if multiple people do it, however, as long as they're all associated with the same organization.


6. Do I really have to use my real email address?

A confirmation token is sent to your email address, so yes, you really should.


7. Why should I care?

Project owners include Supported Source in their projects for good reason. They're investing a lot of their time and energy into creating and maintaing the projects. In return, they're just asking to know who's using their project. They might also want to email you for various reasons, like asking how you're using the project or to understand what to prioritize next on the development roadmap. And, like all email platforms, you're free to opt out of receiving messages from the project.

In summary, these project owners are doing a lot of work for your benefit - the least you can do is help them understand who's using their project!
