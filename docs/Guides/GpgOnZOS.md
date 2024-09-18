# **GPG ON z/OS**


### What is GPG?

GPG stands for "GNU Privacy Guard," which is a free and open-source software application used for encrypting and decrypting data. It is based on the OpenPGP (Pretty Good Privacy) standard, which provides cryptographic privacy and authentication for data communication.

GPG uses a combination of symmetric-key and public-key cryptography to secure data. Symmetric-key cryptography involves using the same key for both encryption and decryption, while public-key cryptography uses a pair of keys: a public key for encryption and a private key for decryption.

GPG allows users to generate key pairs consisting of a public key and a private key. The public key can be freely distributed, while the private key must be kept secret. With GPG, users can encrypt data using the recipient's public key, ensuring that only the intended recipient can decrypt and access the information using their private key.

GPG also supports digital signatures, which provide a way to verify the authenticity and integrity of data. By signing a document with their private key, a user can demonstrate that the document has not been tampered with and was indeed created by them. The signature can be verified using the corresponding public key.

Overall, GPG is commonly used for secure communication, email encryption, file encryption, and verifying the authenticity of software distributions. It is widely regarded as a reliable and trusted tool for ensuring privacy and security in digital communications.



### How do I generate a GPG key?

In the terminal, enter the following command to generate a new GPG key pair:

	gpg --generate-key

This command initiates the key generation process.


You will be prompted enter your name and email address: Provide your full name and the email address associated with the key. This information will be included in the key's metadata.

Set a passphrase: You will be prompted to set a passphrase for your key. This passphrase will protect your private key and should be strong and memorable. Type in a passphrase and press Enter. Make sure to choose a secure passphrase and keep it confidential.

Once the key generation process is complete, GPG will display information about your new key pair, including the key ID and fingerprint. The key ID is used to identify your key, and the fingerprint is a unique identifier for your key pair. You can use this information to share your public key with others.

	pub   rsa3072 2021-02-09 [SC] [expires: 2022-02-09]
	      3782CBB60147010B330523DD26FBCC7836BF353A
	uid                      John Doe (ZOS Open tools) <johndoe@example.com>
	sub   rsa3072 2021-02-09 [E] [expires: 2022-02-09]

### How do I view key fingerprint?

A key fingerprint is a representation of the key's characteristics and serves as a reliable way to verify the integrity and authenticity of a key. To display the fingerprint at any time, use this command, substituting your email address

	gpg --fingerprint <email id>
	
Your GPG key ID consists of 8 hex digits identifying the public key. In the example above, the GPG key ID is `36BF353A`. 

### How do I get your public key and store it?


If you want to give or send a file copy of your key to someone, use this command to write it to an ASCII text file:

`gpg --export --armor <email id> > <name>-pubkey.asc`	

### How do I Sign Git commits using GPG key?

1. Add your public GPG Key to your account on github.com and refer the [link](https://docs.github.com/en/authentication/managing-commit-signature-verification/adding-a-gpg-key-to-your-github-account) for steps.

2. Tell git about your public key which will be used for signing. You can get steps from [here](https://docs.github.com/en/authentication/managing-commit-signature-verification/telling-git-about-your-signing-key#telling-git-about-your-gpg-key)

3. Now you can sign your commit using command (provide your phrase on prompt)

	`git commit -S -m "YOUR_COMMIT_MESSAGE"`
	
4. 	When you've finished creating commits locally, push them to your remote repository on GitHub:

	`git push `
5. 	On GitHub, navigate to your pull requestO and on the pull request, click  Commits. To view more detailed information about the verified signature, click `Verified`.


### How do I sign files?
1. Any file can be signed using command below.

	`gpg --output <file.name>.sig --sign <file-name>`
	
2. 	Signed file can be verified using:

	`gpg --verify <file.name>.sig`
	
3. 	To verify the signature and extract the file use the --decrypt option. The signed file to verify and recover is input and the recovered document is output.

	`gpg --output zoslib-zopen.20230511_114620.zos.pax.Z --decrypt zoslib-zopen.20230511_114620.zos.pax.Z.gpg`
	

### How do I create detached signature and sign a file?

1. A detached signature can be created and a file can signed using the following command:

	`gpg --output <file.name>.sig --detach-sig <file-name>` 
	
2. 	Both file and the detached signature are needed to verify the signature using --verify option:

	`gpg --verify <file.name>.sig <file.name>`
	
### Example:

1. Download signed bash tool in tar.gz.sig format using command shown below:

	`curl -k -O http://ftp.vim.org/ftp/ftp/gnu/bash/bash-5.2.15.tar.gz.sig`

2. Download the bash tool in tar.gs format using command below:

	`curl -k -O http://ftp.vim.org/ftp/ftp/gnu/bash/bash-5.2.15.tar.gz`
	
3. 	Download the public GNU keyring using command shown below:

	`curl -k -O https://ftp.gnu.org/gnu/gnu-keyring.gpg` 
	
4. 	Verify the downloaded tar file, using command:

	`gpg --verify --keyring ./gnu-keyring.gpg bash-5.2.15.tar.gz.sig`
	
5. 	The output of the step 4 is:

	`gpg: Signature made Tue Dec 13 12:13:54 2022 EST`
	`gpg:                using DSA key 7C0135FB088AAF6C66C650B9BB5869F064EA74AB`
	`gpg: Good signature from "Chet Ramey <chet@cwru.edu>" [unknown]`
	
	
### Resources 
* [GPG Home Page](https://gnupg.org/index.html)
* To install GPG on z/OS systems [visit](https://github.com/zopen-community/gpgport/releases)
	






