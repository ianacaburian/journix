**Source:** [Practical Nix Flakes](https://serokell.io/blog/practical-nix-flakes)   

## What is Nix?

- Allows to write declarative scripts for reproducible software builds. 
- Helps to test and deploy software systems while using the functional programming paradigm. 
- [nixpkgs](https://github.com/nixos/nixpkgs) is a vast repository of packages for Nix.
- [NixOS](https://nixos.org/) is a GNU/Linux distribution that extends the ideas of Nix to the OS level.
- Nix building instructions are called “derivations” and are written in the [Nix programming language](https://serokell.io/nix-development). 
- Derivations can be written for packages or even entire systems. After that, they can then be deterministically “realised” (built) via Nix, the package manager. 
- Derivations can only depend on a pre-defined set of inputs, so they are somewhat reproducible.
- Read more [on Nix](https://serokell.io/blog/what-is-nix).

## What are Nix flakes?

- Flakes are self-contained units that have:
	- Inputs (dependencies).
	- Outputs (packages, deployment instructions, Nix functions for use in other flakes). 
- Flakes have great reproducibility because they are only allowed to depend on their inputs and they pin the exact versions of said inputs in a lockfile.

## Getting a feel for flakes

### `nix shell`

>1. First, let’s enter a shell that has GNU Hello from nixpkgs’ branch `nixpkgs-unstable` in it:
> ```sh
>nix shell github:nixos/nixpkgs/nixpkgs-unstable#hello
>```
>- This will start the same shell as you are running, but add a directory containing the `hello` executable to your `$PATH`.
>- The shell shouldn’t look any different from how it was outside the `nix shell`, so don’t panic if it looks like nothing is happening! 
>- The executable is not installed anywhere per se, it gets downloaded and unpacked in what you can consider a cache directory.

>2. Now, inside that shell, try running `hello`.
>- `nix shell` is a nix subcommand that is used to run a shell with some packages available in `$PATH`. 
>- Those packages can be specified as arguments in the “installable” format. 
>- Each installable contains two parts: 
>	- The URL (`github:nixos/nixpkgs/master` in this case).
>	- An “attribute path” (`hello` here).
>- There are a few URL schemes supported:
>	- `github:owner/repo/[revision or branch]` and `gitlab:owner/repo/[revision or branch]` (for public repositories on [github.com](http://github.com/) and [gitlab.com](http://gitlab.com/); note that that the branch name cannot contain slashes).
>	- `https://example.com/path/to/tarball.tar.gz` for tarballs.
>	- `git+https://example.com/path/to/repo.git` and `git+ssh://example.com/path/to/repo.git` for plain git repositories (you can, of course, use this for GitHub and GitLab). You can specify the branch or revision by adding `?ref=<branch name here>`.
>	- `file:///path/to/directory` or `/path/to/directory` or `./path/to/relative/directory` for a local directory.
>	- `flake-registry-value` for a value from a flake registry (I won’t talk about flake registries in this article).

>3. So, there are some other ways to get the same shell:
>```sh
>nix shell https://github.com/nixos/nixpkgs/archive/nixpkgs-unstable.tar.gz#hello
>nix shell 'git+https://github.com/nixos/nixpkgs?ref=nixpkgs-unstable#hello'
>nix shell nixpkgs#hello # nixpkgs is specified in the default registry to be github:nixos/nixpkgs
>```
>- As for the attribute path, for now, just know that it’s a period-separated list of Nix “attribute names” that selects a flake output according to some simple logic.
>- Note that in this case, Nix did not have to build anything since it could just fetch GNU Hello and its dependencies from the binary cache. 
>	- To achieve this, 
>		1. Nix evaluates a _derivation_ from the expression, 
>		2. Hashes its contents, and 
>		3. Queries all the caches it knows to see if someone has the derivation with this hash cached. 
>	- Nix uses all the dependencies and all the instructions as the input for this hash! 
>		- If some binary cache has a version ready, it can be _substituted_ (downloaded). 
>		- Otherwise, Nix will build the derivation by first realising (substituting or building) all the dependencies and then executing the build instructions.

>4. You might be wondering where exactly is the executable installed. Well, try `command -v hello` to see that it is located in a subdirectory of `/nix/store`. 
>	- In fact, all Nix _derivations_ have “store paths” (paths located in `/nix/store`) as inputs and outputs.

### `nix build`

>1. If you just want to build something instead of entering a shell with it, try `nix build`:
>```sh
>nix build nixpkgs#hello
>```
>- This will build Hello (or fetch it from the binary cache if available) and then symlink it to `result` in your current directory.

>2. You can then explore `result`, e.g.
>```sh
>$ ./result/bin/hello
>Hello, world!
>```

### `nix develop`

- Despite the use of binary caches, Nix is a sourcecode-first package manager. 
	- This means that it has the ability to provide a build environment for its derivations. 
	- So, you can use Nix to manage your build environments for you! 
 
>- To enter a shell with all runtime and buildtime dependencies of GNU Hello, use:
>```sh
>nix develop nixpkgs#hello
>```
>- Inside that shell, you can 
	>- 1. Call `unpackPhase` to place GNU Hello sources in the current directory, then 
	>- 2. `configurePhase` to run `configure` script with correct arguments and finally 
	>- 3. `buildPhase` to build.

### `nix profile`

- Nix implements stateful “profiles” to allow users to “permanently” install stuff.
- If you’re already familiar with Nix, this is a replacement for `nix-env`.
	```sh
	nix profile install nixpkgs#hello
	nix profile list
	```

###  `nix flake`

- Used to observe and manipulate flakes themselves rather than their outputs.

>1. `nix flake show` takes a flake URI and prints all the outputs of the flake as a nice tree structure, mapping attribute paths to the types of values. For example:
>	```
>	$ nix flake show github:nixos/nixpkgs
>	github:nixos/nixpkgs/d1183f3dc44b9ee5134fcbcd45555c48aa678e93
>	├───checks
>	│ └───x86_64-linux
>	│ └───tarball: derivation 'nixpkgs-tarball-21.05pre20210407.d1183f3'
>	├───htmlDocs: unknown
>	├───legacyPackages
>	│ ├───aarch64-linux: omitted (use '--legacy' to show)
>	│ ├───armv6l-linux: omitted (use '--legacy' to show)
>	│ ├───armv7l-linux: omitted (use '--legacy' to show)
>	│ ├───i686-linux: omitted (use '--legacy' to show)
>	│ ├───x86_64-darwin: omitted (use '--legacy' to show)
>	│ └───x86_64-linux: omitted (use '--legacy' to show)
>	├───lib: unknown
>	└───nixosModules
>	└───notDetected: NixOS module
>	```
 
>2. `nix flake clone` will clone the flake source to a local directory, similar to `git clone`.
>```sh
>nix flake clone git+https://github.com/balsoft/hello-flake/ -f hello-flake
>cd hello-flake
>```

>3. `nix flake lock` (previously `nix flake update`)
>	- Every time you call a Nix command on some flake in a local directory, Nix will make sure that the contents of `flake.lock` satisfy the `inputs` in `flake.nix`. 
>	- If you want to do just that, without actually building (or even evaluating) any outputs, use `nix flake lock`.

>4. There are also some arguments for flake input manipulation that can be passed to most Nix commands: 
>	- `--override-input` takes an input name that you have specified in `inputs` of `flake.nix` and a flake URI to provide as this input
>	- `--update-input` will take an input name and update that input to the latest version satisfying the flake URI from `flake.nix`.

## Writing your own

###  Nix language refresher

- The widely used data type in Nix is an attribute set: a data type for storing key-value pairs. 
	- It is similar to a JSON object or a hashmap in many languages. 
```nix
{
  hello = "world";
  foo = "bar";
}
```

- The set above is equivalent to this JSON object:
	- `hello` and `foo` are commonly referred to as “attributes” or “attribute names”.
	- `"world"` and `"bar"` are “attribute values”.
```json
{
    "hello": "world",
    "foo": "bar"
}
```

- To get an attribute value from an attribute set, use `.`. 
- `let ... in` is a way to create bindings.
	- The syntax inside it is identical to that of an attribute set.
```nix
let
  my_attrset = { foo = "bar"; };
in my_attrset.foo
```

- You can also abbreviate your attribute set by setting specific attributes with `.` instead of defining the entire set:
```nix
{
  foo.bar = "baz";
}
```
- Is equivalent to:
```nix
{
  foo = { bar = "baz"; };
}
```

- Other types include:
	- Strings (`"foo"`),
	- Numbers (1, 3.1415), 
	- Heterogenous lists (`[ 1 2 "foo" ]`) and 
	- Functions (`x: x + 1`).
		- Functions support pattern matching on attribute sets. 
			- For example, the function `{ a, b }: a + b` called with `{ a = 10; b = 20; }` will return 30.
		- Function application is done in ML style:
			- The function itself comes first, then a whitespace-separated list of arguments.
```nix
let
  f = { a, b }: a + b;
in f { a = 10; b = 20; }
```

- If you want to have a function of multiple arguments, use currying:
	- In this example, `f 10` evaluates to `b: 10 + b`, and then `f 10 20` evaluates to `30`.
```nix
let
  f = a: b: a + b;
in f 10 20
```

- To learn more about Nix, check out 
	- The [corresponding manual section](https://nixos.org/manual/nix/stable/#chap-writing-nix-expressions) 
	- [Nix Pills](https://nixos.org/guides/nix-pills/).

### Basic flake structure

- A Nix flake is a directory that contains a `flake.nix` file. 
	- That file must contain an attribute set with 
		- One required attribute `outputs`, and 
		- Optionally `description` and `inputs`.
- `outputs` is a function that takes an attribute set of inputs.
	- There’s always at least one input – `self` – which refers to the flake that Nix is currently evaluating
		- This is possible due to laziness). 
- So, the most trivial flake possible is a flake with no external inputs and no outputs:
```nix
{
  outputs = { self }: { };
}
```

>1. Add an arbitrary output and evaluate it with `nix eval` (in a newly created flake.nix file):
>```nix
>{
>  outputs = { self }: {
>    foo = "bar";
>  };
>}
>```
>
>```sh
>$ nix eval .#foo
>"bar"
>```
>> If a "no such file or directory" error is encountered, try staging the flake.nix file with `git add .`.

>2. Add some inputs:
>```nix
>{
>  inputs = {
>    nixpkgs.url = "github:nixos/nixpkgs";
>  };
>
>  outputs = { self, nixpkgs }: { };
>}
>```

- While the attribute set that `outputs` returns may contain arbitrary attributes, some standard outputs are understood by various `nix` utilities. 
	- For example, there is a `packages` output that contains packages.  

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
  };

  outputs = { self, nixpkgs }: {
    packages.x86_64-linux.hello = /* something here */;
  };
}
```

- Flakes promise us _hermetic evaluation_, which means that the outputs of a flake should be the same regardless of the evaluator’s environment. 
	- One particular property of the evaluating environment that’s very relevant in a build system is the _platform_ 
		- A combination of architecture and OS. 
	- Because of this, all flake outputs that have anything to do with packages must specify the platform explicitly in some way.  
	- The standard way is to make the output be an attribute set with names being platforms and values being whatever the output semantically represents, but built specifically for that platform. 
	- In the case of `packages`, each per-platform value is an attribute set of packages.
		- E.g. `packages.x86_64-linux`.
- Nix specifies the platform automatically, so that we write `nix build nixpkgs#hello` and get a package without explicitly specifying the platform.  
	- For `nix shell`, `nix build`, `nix profile`, and `nix develop` (among some other commands), Nix tries to figure out which output you want by trying multiple in a specific order. 
	- Let’s say you do `nix build nixpkgs#hello` on an x86_64 machine running Linux. Then Nix will try:
		- `hello`
		- `packages.x86_64-linux.hello`
		- `legacyPackages.x86_64-linux.hello`
- `legacyPackages` is designed specifically for nixpkgs. 
	- The nixpkgs repository is a lot older than flakes, so it is impossible to fit its arbitrary attribute format into neat `packages`. 
	- `legacyPackages` was devised to accomodate the legacy mess. 
	- In particular, `legacyPackages` allows per-platform packagesets to be arbitrary attribute sets rather than structured packages.

>3. Reexport and build or run `hello` from nixpkgs in our own flake:
>	- By default, `nix run` will execute the binary with the same name as the attribute name of the package.
>```nix
>{
>  inputs = {
>    nixpkgs.url = "github:nixos/nixpkgs";
>  };
>
>  outputs = { self, nixpkgs }: {
>    packages.x86_64-linux.hello = nixpkgs.legacyPackages.x86_64-linux.hello;
>  };
>}
>```
>- Build:
>```sh
>nix build .#hello
>```
>- Run:
>```sh
>$ nix run .#hello
>Hello, world!
>```

>4. Another thing we can add is a “development” shell containing some utilities that might be useful when working on our flake. 
>	- In this example, maybe we want to have `hello` and `cowsay` in `$PATH` to print the friendly greeting and then make the cow say it. 
>	- There is a special output for such development shells, called `devShell`. 
>	- There is also a function for building such shells in nixpkgs. 
>	- To prevent writing the unwieldy `nixpkgs.legacyPackages.x86_64-linux` multiple times, let’s extract it via a `let ... in` binding:
>```nix
>{
>  inputs = { nixpkgs.url = "github:nixos/nixpkgs"; };
>
>  outputs = { self, nixpkgs }:
>    let pkgs = nixpkgs.legacyPackages.x86_64-linux;
>    in {
>      packages.x86_64-linux.hello = pkgs.hello;
>
>      devShell.x86_64-linux =
>        pkgs.mkShell { buildInputs = [ self.packages.x86_64-linux.hello pkgs.cowsay ]; };
>   };
>}
>```

>5. Now we can enter the development environment with `nix develop`. 
>	- If you want to run a shell other than Bash in that environment, you can use `nix shell -c $SHELL`.
>```sh
>$ nix develop -c $SHELL
>$ hello | cowsay
> _______________
>< Hello, world! >
> ---------------
>        \   ^__^
>         \  (oo)\_______
>            (__)\       )\/\
>                ||----w |
>                ||     ||
>```

Let’s examine our flake using `nix flake show`:

```
$ nix flake show
path:/path/to/flake
├───devShell
│    └───x86_64-linux: development environment 'nix-shell'
└───packages
      └───x86_64-linux
            └───hello: package 'hello-2.10'
```

Now that we’ve written our slightly useful “hello” flake, time to move to practical applications!

### Some tips and tricks

- You can use [direnv](https://direnv.net/) with [nix-direnv](https://github.com/nix-community/nix-direnv) to automatically enter `devShell` when you change directory into the project which is packaged in a flake. 
- There is a library that helps you extract the boring per-platform attrsets away: [`flake-utils`](https://github.com/numtide/flake-utils). 
	- If we use flake-utils in our example flake, we can make it support all the nixpkgs platforms with practically no extra code:
		- Note how now there are more platforms in the output of `nix flake show`.
		- All the platform attributes are inserted automatically by flake-utils.
```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system};
      in {
        packages.hello = pkgs.hello;

        devShell = pkgs.mkShell { buildInputs = [ pkgs.hello pkgs.cowsay ]; };
      });
}
```

# Resources
- [nixpkgs](https://github.com/nixos/nixpkgs)   
- [Nix programming language](https://serokell.io/nix-development)   
- [What is Nix](https://serokell.io/blog/what-is-nix)   
- [Writing Nix Expressions](https://nixos.org/manual/nix/stable/#chap-writing-nix-expressions)    
- [Nix Pills](https://nixos.org/guides/nix-pills/)   
- [`flake-utils`](https://github.com/numtide/flake-utils)   