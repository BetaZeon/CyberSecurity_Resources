Cyber Security Tutorial
Cyber Security Tutorial
Cyber Security tutorial provides basic and advanced concepts of Cyber Security technology. 
Our Cyber Security tutorial is designed for beginners and professionals.

Our Cyber Security Tutorial includes all topics of Cyber Security such as what is Cyber Security, cyber security goals, 
types of cyber attacks, types of cyber attackers, technology, e-commerce, policies, digital signature, cyber security tools, security risk analysis, challenges etc.

Prerequisites
Before Learning Cyber Security, you must have the knowledge of web applications, system administration, C, C++. Java, PHP, Perl, Ruby, Python, networking and VPN's, 
hardware and software (linux OS's, MS, Apple).

1. Economy of mechanism
This principle states that Security mechanisms should be as simple and small as possible. The Economy of mechanism principle simplifies the design and implementation of security mechanisms. If the design and implementation are simple and small, fewer possibilities exist for errors. The checking and testing process is less complicated so that fewer components need to be tested.

Interfaces between security modules are the suspect area which should be as simple as possible. Because Interface modules often make implicit assumptions about input or output parameters or the current system state. If the any of these assumptions are wrong, the module's actions may produce unexpected results. Simple security framework facilitates its understanding by developers and users and enables the efficient development and verification of enforcement methods for it.

2. Fail-safe defaults
The Fail-safe defaults principle states that the default configuration of a system should have a conservative protection scheme. This principle also restricts how privileges are initialized when a subject or object is created. Whenever access, privileges/rights, or some security-related attribute is not explicitly granted, it should not be grant access to that object.

Example: If we will add a new user to an operating system, the default group of the user should have fewer access rights to files and services.

3. Least Privilege
This principle states that a user should only have those privileges that need to complete his task. Its primary function is to control the assignment of rights granted to the user, not the identity of the user. This means that if the boss demands root access to a UNIX system that you administer, he/she should not be given that right unless he/she has a task that requires such level of access. If possible, the elevated rights of a user identity should be removed as soon as those rights are no longer needed.

4. Open Design
This principle states that the security of a mechanism should not depend on the secrecy of its design or implementation. It suggests that complexity does not add security. This principle is the opposite of the approach known as "security through obscurity." This principle not only applies to information such as passwords or cryptographic systems but also to other computer security related operations.

Example: DVD player & Content Scrambling System (CSS) protection. The CSS is a cryptographic algorithm that protects the DVD movie disks from unauthorized copying.

5. Complete mediation
The principle of complete mediation restricts the caching of information, which often leads to simpler implementations of mechanisms. The idea of this principle is that access to every object must be checked for compliance with a protection scheme to ensure that they are allowed. As a consequence, there should be wary of performance improvement techniques which save the details of previous authorization checks, since the permissions can change over time.

Whenever someone tries to access an object, the system should authenticate the access rights associated with that subject. The subject's access rights are verified once at the initial access, and for subsequent accesses, the system assumes that the same access rights should be accepted for that subject and object. The operating system should mediate all and every access to an object.

Example: An online banking website should require users to sign-in again after a certain period like we can say, twenty minutes has elapsed.

6. Separation of Privilege
This principle states that a system should grant access permission based on more than one condition being satisfied. This principle may also be restrictive because it limits access to system entities. Thus before privilege is granted more than two verification should be performed.

Example: To su (change) to root, two conditions must be met-

The user must know the root password.
The user must be in the right group (wheel).
7. Least Common Mechanism
This principle states that in systems with multiple users, the mechanisms allowing resources shared by more than one user should be minimized as much as possible. This principle may also be restrictive because it limits the sharing of resources.

Example: If there is a need to be accessed a file or application by more than one user, then these users should use separate channels to access these resources, which helps to prevent from unforeseen consequences that could cause security problems.

8. Psychological acceptability
This principle states that a security mechanism should not make the resource more complicated to access if the security mechanisms were not present. The psychological acceptability principle recognizes the human element in computer security. If security-related software or computer systems are too complicated to configure, maintain, or operate, the user will not employ the necessary security mechanisms. For example, if a password is matched during a password change process, the password changing program should state why it was denied rather than giving a cryptic error message. At the same time, applications should not impart unnecessary information that may lead to a compromise in security.

Example: When we enter a wrong password, the system should only tell us that the user id or password was incorrect. It should not tell us that only the password was wrong as this gives the attacker information.

9. Work Factor
This principle states that the cost of circumventing a security mechanism should be compared with the resources of a potential attacker when designing a security scheme. In some cases, the cost of circumventing ("known as work factor") can be easily calculated. In other words, the work factor is a common cryptographic measure which is used to determine the strength of a given cipher. It does not map directly to cybersecurity, but the overall concept does apply.

Example: Suppose the number of experiments needed to try all possible four character passwords is 244 = 331776. If the potential attacker must try each experimental password at a terminal, one might consider a four-character password to be satisfactory. On the other hand, if the potential attacker could use an astronomical computer capable of trying a million passwords per second, a four-letter password would be a minor barrier for a potential intruder.

10. Compromise Recording
The Compromise Recording principle states that sometimes it is more desirable to record the details of intrusion that to adopt a more sophisticated measure to prevent it.

