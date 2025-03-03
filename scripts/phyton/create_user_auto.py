import subprocess

def create_user(username, password):
    try:
        # Create a new user
        subprocess.run(['sudo', 'useradd', '-m', '-s', '/bin/bash', username], check=True)
        
        # Set the password for the user
        subprocess.run(['sudo', 'chpasswd'], input=f"{username}:{password}", encoding='utf-8', check=True)
        
        print(f"User {username} has been created successfully.")
    except subprocess.CalledProcessError as e:
        print(f"Error occurred while creating the user: {e}")

if __name__ == "__main__":
    # Define the username and password directly
    username = "fraud"  # Replace with the desired username
    password = "28cbyb[vjhzxrjd"  # Replace with the desired password
    
    # Create the user
    create_user(username, password)