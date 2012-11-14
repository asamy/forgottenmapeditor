### Forgotten Map Editor

A Map editor written using otclient's framework with modifications for reading and writing OT binary files and XML files.

Please read the wiki if you would like to try it out or have a problem.  If your problem has no workaround written in the wiki, consider using the bug-tracker system in github (Issues).

## Authors

fallen <f.fallen45@gmail.com>

edubart <edub4rt@gmail.com> and others.

## License

Licensed under MIT,  see LICENSE for more information.

## Screenshots

Here's a screenshot as of Monday, Sep 24, 2012.

![Screenshot](http://i.imgur.com/CZVqM.jpg)

## See Also

[OTClient](https://github.com/edubart/otclient)

## Building

Linux:

```sh
git clone git://github.com/otfallen/forgottenmapeditor
git submodule init && git submodule update
cd otclient
mkdir -p build && cd build
cmake .. -DCMAKE_BUILD_TYPE=Release -DPCH=ON
make
```

Windows:
    1. Install Git from the Gitscm website
    2. Fire up Git bash
    3. Type out the following commands:
        ```sh
        git clone git://github.com/otfallen/forgottenmapeditor
        git submodule init && git submodule update
        cd otclient
        mkdir -p build && cd build
        ```
    4. Follow otclient build guide.

## Running

```sh
cd .. # get back the root dir
mv otclient/build/otclient .
./otclient
```
For windows, just remove the prepended ./

