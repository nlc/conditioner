# conditioner
## "Condition" a remote machine's environment to your preferences.

### What is it?
`conditioner` accepts a list of scripts that you want to run on a remote machine and turns them into one giant compressed/base64'd command to be pasted into the remote machine's terminal. Is it safe? No way! Use at your own risk.

### Example
I want to add my aliases to a machine that I usually connect to over ssh. I can create a script to do so:

```bash
# scripts/append_my_aliases.sh
echo "alias hw='echo hello world'" >> ~/.bashrc
```

and place it in the `scripts` directory. When I `source conditioner.sh`, it generates a single command from all of the scripts in the `scripts` directory, which can be copied and pasted into the remote session and work as though those scripts had been run locally on the remote machine.

```
(local)$ source conditioner.sh
Run "conditioner_command" to generate the command.
Run "conditioner_import_dotfile" to import a dotfile.
(local)$ conditioner_command
echo 'H4sIAAAAAAACA22NQQqDQBAE776iGQ/e9AXxJYKMs0tGWHeWHUVyydsNEsglx+pqqBZcSsxh3l4zp5U9eu/atHCpa9l9+KujqIHuAXo+ups1pmQ4rabQEcYR76Ff2LXK91+PjIncjirxJyfCbkjGAaKcn58CNRdmuxT5lwAAAA==' | base64 -d | gunzip | bash
```

Copying the output of the command, I ssh into my remote machine and paste it into the prompt:

```
(local)$ ssh username@50.28.52.163
Welcome to Remote!
[remote]$ hw # alias doesn't exist yet
hw: command not found
[remote]$ echo 'H4sIAAAAAAACA22NQQqDQBAE776iGQ/e9AXxJYKMs0tGWHeWHUVyydsNEsglx+pqqBZcSsxh3l4zp5U9eu/atHCpa9l9+KujqIHuAXo+ups1pmQ4rabQEcYR76Ff2LXK91+PjIncjirxJyfCbkjGAaKcn58CNRdmuxT5lwAAAA==' | base64 -d | gunzip | bash
[remote]$ source ~/.bashrc # source the changed ~/.bashrc
[remote]$ hw
hello world
[remote]$ # it works!
```

### The Importer
You can also "import" your dotfiles into the `scripts` directory using `conditioner_import_dotfile`. The next time you run `conditioner_command` it will generate a command that appends your dotfile contents onto the matching dotfile on the machine the command is run on.

### Disclaimer
- As with anything that involves running someone else's code on your machine, this is potentially very dangerous. Use at your own risk.
- This was developed with and for Bash v5. I have done some minimal testing with zsh that seems to indicate that it works there as well, but no guarantees.
