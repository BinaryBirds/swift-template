# swift-template

A template based generator for Swift projects.

## Install

Clone or download the repository & run:

```shell
git clone https://github.com/BinaryBirds/swift-template.git
cd swift-template
make install
```


## Usage

Help:
```shell
swift run swift-template-cli --help
```

Install a new template using a git repository:
``` 
swift template install <git-url-of-the-template> [-g]

# install local template
swift template install https://github.com/corekit/viper-module-template

# install global template
swift template install https://github.com/feathercms/feather-module-template -g
```

Update all templates, both local & global:
```shell
swift template update
```

List available templates:
```shell
swift template list
```

Remove template:
```shell
swift template remove [template-name]
```

Create an empty template project repository:
```shell
swift template create [template-name] [-g]
```

Generate a new module based on a template
```shell
swift template generate [name] --use [template-name] --output [path]

# examples
swift template generate MyModule --use viper-module
swift template generate MyModule --use viper-module --output ~/
swift template generate MyModule -u viper-module -o ~/
```


## Scope

Templates can be stored locally or globally inside the `.swift-template` directory.
Local templates are being loaded from the current work dir, globals from the home folder.
The system will prefer local templates (with the same name) over the global ones.


## Parameters

You can use the following parameters in the templates (even in file names):

- name - given module name
- Name - given module name (capitalized first letter)
- NAME - given module name (uppercased)

- project - based on `.xcodeproj` or `.xcworkspace` name or input name
- author - based on git config user name
- date - current date in local short format

eg. {name} -> MyModule


## License

[WTFPL](LICENSE) - Do what the fuck you want to.

