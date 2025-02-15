import os  # Import the os module for interacting with the operating system 
import smtplib  # Import the smtplib module for sending emails

FLEET_NODES = ["<RASPBERRY_PI_IP>"]  # List of IP addresses of the fleet nodes to monitor.  REPLACE <RASPBERRY_PI_IP> with the actual IP.
ALERT_EMAIL = "admin@example.com"  # Email address to send alerts to.  REPLACE with the actual admin email.

def check_node(ip):
    """Checks if a node is online by pinging it.

    Args:
        ip: The IP address of the node to check.

    Returns:
        True if the node is online (ping successful), False otherwise.
    """
    response = os.system(f"ping -c 1 {ip} > /dev/null 2>&1") # Ping the IP address once (-c 1).  > /dev/null 2>&1 suppresses output.
    return response == 0  # os.system returns 0 if the command is successful.

for node in FLEET_NODES:  # Iterate through the list of fleet nodes.
    if not check_node(node):  # If a node is offline (ping fails).
        try: # Try to send the email. This is very important to make sure the script continues to check other nodes even if email sending fails.
            server = smtplib.SMTP("smtp.example.com", 587)  # Connect to the SMTP server.  REPLACE with your SMTP server details.
            server.starttls()  # Start TLS encryption (secure connection).
            server.login("your-email@example.com", "password")  # Login to the SMTP server.  REPLACE with your email credentials.
            message = f"Subject: Fleet Alert\n\nFleet node {node} is offline."  # Construct the email message.
            server.sendmail("your-email@example.com", ALERT_EMAIL, message)  # Send the email.
            server.quit()  # Close the connection to the SMTP server.
        except Exception as e: # Catch any exceptions that might occur during email sending
            print(f"Error sending email: {e}") # Print the error message. This is useful for debugging.
