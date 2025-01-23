# Classless
Module to make a classless game mode. A new character starts in a blank state where you can make the build that you wish. Spells will appear randomly while you progress the game in the form of lootable books.

It's recommended to use warrior classes as a base.

# Available Cores
Classic

# How to install
1. Follow the instructions in https://github.com/davidonete/cmangos-modules?tab=readme-ov-file#how-to-install
2. Enable the `BUILD_MODULE_CLASSLESS` flag in cmake and run cmake. The module should be installed in `src/modules/classless`.
3. Copy the configuration file from `src/modules/classless/src/classless.conf.dist.in` and place it where your mangosd executable is. Also rename it to `classless.conf`.
4. Remember to edit the config file and modify the options you want to use.
5. You will also have to install the database changes located in the `src/modules/classless/sql/install` folder, each folder inside represents where you should execute the queries. E.g. The queries inside of `src/modules/classless/sql/install/world` will need to be executed in the world/mangosd database, the ones in `src/modules/classless/sql/install/characters` in the characters database, etc...

# How to uninstall
To remove transmog from your server you have to remove it from the db and client:
1. Remove the `BUILD_MODULE_CLASSLESS`` flag from your cmake configuration and recompile the game
2. Execute the sql queries located in the `src/modules/classless/sql/uninstall` folder. Each folder inside represents where you should execute the queries. E.g. The queries inside of `src/modules/classless/sql/uninstall/world` will need to be executed in the world/mangosd database, the ones in `src/modules/classless/sql/uninstall/characters` in the characters database, etc...
3. Remove the patch files from the client added in the installation phase.