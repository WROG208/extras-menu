# Extras-menu
## **** 6/7/2024 UPDATE.....
## I completely spaced out and forgot to add the links for the dependencies needed by this. FFMPEG  PIP  and PYTHON (Already installed in the system) Now the first time you run the install it will check for those dependencies and if they are not there it will download and install. I am working on some more scripts that will add some things to the supermon page and i have some other ideas the thing is getting them to all work together.

## A collection of different scripts to use in GMRSlive.
### Might also work on Allstar but I did not test it so use it at your own risk.
### I am not liable for whatever happens to your NODE. 
### I tested on a Raspberry Pi 3B+ Running GMRSLive v2.1.3 image and except for gTTS (Google Text To Speech) nothing else needs to be installed. All that is needed it's already on the Pi.


### Some of these scripts already have a version of them in the GMRSlive image, they are not that easy to use and all are command line. For a newbie who doesn't know his way around the BASH Shell or command prompt, I hope I made it a bit easier.

## Scripts included
- menu.sh----This is the menu like when you first sign into the Pi.
- global.sh----Changes information on the global.inc to change the text on the top part of the supermon page.
- cronJ.sh----To make CRON jobs easier instead of using crontab -e Please be careful with this if you don't know how to use it leave it ALONE.
- gsmbi.py----To convert Text into a sound file that Asterisk can use.
- *astdb.php----To update the database. Helpful when your Supermon page only says NODE not in database
- *cpu_stats.sh----Status of the CPU of the Pi.
- *reboot.sh----Reboot the system
- *firsttime.sh---- The same script you used the first time you set up your node.
- The scripts with a * are already on the Pi. I am just making it easier to use.


## Step 1 Open Putty and sign into the Pi you will be installing this too.

![admin window](https://github.com/WROG208/extras-menu/assets/147953407/eac9e73a-42f5-409b-aebc-94d89a85f245)
### Chose option 9 Start Bash shell interface

![bash](https://github.com/WROG208/extras-menu/assets/147953407/3baee1ad-ff75-45a9-8d56-4eb24e7e3c9a)
### You should be on this screen now. 
TYPE
```
CD and enter
```

## Installation

Follow these steps to install the scripts:

1. Clone the repository. Type this and hit enter to download the repository.
    ```sh
    git clone https://github.com/WROG208/extras-menu.git
    ```

2. Change to the repository directory:
    ```sh
    cd extras-menu
    ```

3. Make the install script executable:
    ```sh
    chmod +x install_script.sh
    ```

4. Run the install script:
    ```sh
    ./install_script.sh
    ```

5. If the line above didn't work type this:
    ```
    install_script.sh
    ```
    
    The scripts `menu.sh`, `gsmbi.py`, and `cronJ.sh` will be installed to `/usr/local/sbin` and made executable. The installation script and the repository directory will be removed after installation.


6. It should be installed now. Type
    ```
    CD Enter To go back to the ROOT menu.
    ```

7. To get the menu open type
    ```
    menu.sh
    ```
Hit enter, the menu should be open.
The new menu should look like this.

![menu final](https://github.com/WROG208/extras-menu/assets/147953407/2ead93ff-5020-4fd9-b740-8c2980108f5f)
