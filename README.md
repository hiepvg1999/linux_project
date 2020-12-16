# Covid-19's Information Shell

Final project of ITSS Linux - A program to get infomation about covid 19.
```
_________             .__    .___        ____ ________
\_   ___ \  _______  _|__| __| _/       /_   /   __   \
/    \  \/ /  _ \  \/ /  |/ __ |   ____  |   \____    /
\     \___(  <_> )   /|  / /_/ |  /___/  |   |  /    /
 \______  /\____/ \_/ |__\____ |         |___| /____/
        \/                    \/
```
## How to run project

1. Install `curl`, `jq`
```
sudo apt-get install curl
sudo apt-get install jq
```

2. Use repository [imcat](https://github.com/stolk/imcat) to render countries of flag

```
git clone "https://github.com/stolk/imcat"
cd imcat
make
```
3. Create python virtual enviroment for project

```
sudo apt install python3-virtualenv
virtualenv prj_env
source prj_env/bin/activate
pip install -r requirments.txt #install package for project
```
4. Run project
```
./menu
```
