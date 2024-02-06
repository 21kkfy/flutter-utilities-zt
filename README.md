# Accessing Private GitHub Repository using SSH Key

This guide provides step-by-step instructions on how to access a private GitHub repository using an SSH key. By following these steps, a junior Flutter developer can correctly clone the repository and run `flutter pub get` without any issues.

## IMPORTANT

In-order to run & build projects that uses ZeroTech utilities library, you need to setup your SSH key following this guide.
Otherwise, you will not able to run & build these projects.

## Steps

1. **Generate an SSH key pair:**

   - Open a terminal or command prompt.
   - Execute the following command to generate a new SSH key pair:
     ```
     ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
     ```
   - You can replace `"your_email@example.com"` with your own email address or leave it as is.

2. **Specify a location for the SSH key pair:**

   - You will be prompted to enter a file path where the key pair will be saved. Press Enter to accept the default location or specify a custom path.

3. **Set a passphrase (optional):**

   - You can set a passphrase for added security, but it's optional. If you choose to set one, make sure to remember it.

4. **Add the SSH key to your SSH agent (optional):**

   - To avoid entering your passphrase every time you use the SSH key, you can add it to your SSH agent.
   - Start the SSH agent by running the following command:
     ```
     eval "$(ssh-agent -s)"
     ```
   - Add your private key to the SSH agent using the command:
     ```
     ssh-add ~/.ssh/id_rsa
     ```
   - Replace `id_rsa` with the filename of your private key if you chose a different name or path.

5. **Add the public key to your GitHub account:**

   - Open the public key file (`~/.ssh/id_rsa.pub`) in a text editor or use the command `cat ~/.ssh/id_rsa.pub` to display its contents in the terminal.
   - Copy the entire contents of the file.

6. **Log in to your GitHub account and go to "Settings"** (click on your profile picture, then select "Settings").

7. In the left sidebar, click on "SSH and GPG keys".

8. Click on "New SSH key" or "Add SSH key".

9. **Give the key a title** (e.g., "My SSH Key").

10. **Paste the copied public key** into the "Key" field.

11. Click "Add SSH key" or "Save" to save the key to your GitHub account.

12. **Provide the junior developer with access to the private repository:**

    - In your GitHub repository, navigate to "Settings".
    - In the left sidebar, click on "Manage access" or "Collaborators & teams".
    - Add the junior developer's GitHub username or email address and grant appropriate access permissions.

13. **Clone the private repository:**

    - In the terminal or command prompt, navigate to the directory where you want to clone the repository.
    - Execute the following command to clone the repository:
      ```
      git clone git@github.com:<username>/<repository>.git
      ```
      - Replace `<username>` with your GitHub username and `<repository>` with the name of the private repository.

14. **Provide the junior developer with the cloned repository's SSH URL:**

    - Once you have cloned the repository, provide the junior developer with the SSH URL (e.g., `git@github.com:<username>/<repository>.git`).
    - They can use this URL to configure their Flutter project to access the private repository.

That's it! The junior developer should now be able to access the private GitHub repository using their own SSH key.
