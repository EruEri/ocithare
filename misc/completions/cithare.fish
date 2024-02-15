set -l commands add delete export init show generate-password

complete -c cithare -n "__fish_use_subcommand" -l help -d 'Show help information'
complete -c cithare -n "__fish_use_subcommand" -l version -d 'Show version information'
complete -c cithare -n "__fish_use_subcommand" -l change-master-password -d "Change the master password"

complete -c cithare -n "__fish_use_subcommand" -f -a "add" -d 'Add passwords'
complete -c cithare -n "__fish_use_subcommand" -f -a "delete" -d 'Delete passwords'
complete -c cithare -n "__fish_use_subcommand" -f -a "export" -d 'Export passwords'
complete -c cithare -n "__fish_use_subcommand" -f -a "generate-password" -d 'Generate a random password'
complete -c cithare -n "__fish_use_subcommand" -f -a "init" -d 'Initialize cithare'
complete -c cithare -n "__fish_use_subcommand" -f -a "show" -d 'Display passwords'


# cithare add
complete -c cithare -n "__fish_seen_subcommand_from add" -f -r -s m -l mail -d "Choosen mail"
complete -c cithare -n "__fish_seen_subcommand_from add" -f -r -s n -l username -d "Choosen username"
complete -c cithare -n "__fish_seen_subcommand_from add" -f -r -s w -l website -d "Choosen website"
complete -c cithare -n "__fish_seen_subcommand_from add" -f -s r -l replace -d "Replace a password"

# cithare generate-password
complete -c cithare -n "__fish_seen_subcommand_from generate-password or __fish_seen_subcommand_from add" -f -r -s c -l count -d "Set the length of the generated password"
complete -c cithare -n "__fish_seen_subcommand_from generate-password or __fish_seen_subcommand_from add" -f -r -s e -l exclude -d "Exclude <char> from character set"
complete -c cithare -n "__fish_seen_subcommand_from generate-password or __fish_seen_subcommand_from add" -f -s l -d "Include lowercase letter set [a-z]"
complete -c cithare -n "__fish_seen_subcommand_from generate-password or __fish_seen_subcommand_from add" -f -s d -d "Include digit set [0-9]"
complete -c cithare -n "__fish_seen_subcommand_from generate-password or __fish_seen_subcommand_from add" -f -s s -d "Include all printable character that aren't a number or a letter"
complete -c cithare -n "__fish_seen_subcommand_from generate-password or __fish_seen_subcommand_from add" -f -s u -d "Include uppercased letter set [a-z]"

# cithare delete
complete -c cithare -n "__fish_seen_subcommand_from delete" -f -r -s w -l website -d "Delete passwords matching <website>"
complete -c cithare -n "__fish_seen_subcommand_from delete" -f -r -s a -l all -d "Delete all passwords"

# cithare export
complete -c cithare -n "__fish_seen_subcommand_from export" -r -s o -d "Export passwords as json"
complete -c cithare -n "__fish_seen_subcommand_from export" -f -s r -l regex -d "Find the website by matching its name"
complete -c cithare -n "__fish_seen_subcommand_from export" -f -r -s w -l website -d "Specify the site"

switch (uname)
case Darwin
    complete -c cithare -n "__fish_seen_subcommand_from export" -f -s p -l paste -d "Write the password into the pasteboard"
case '*'
    complete -c cithare -n "__fish_seen_subcommand_from export" -f -s x -d "Write  the  password  into  the  clipboard  X selection by invoking xclip(1)"  
end


# cithare init
complete -c cithare -n "__fish_seen_subcommand_from init" -f -s f -l force -d "Force the initialisation"
complete -c cithare -n "__fish_seen_subcommand_from init" -f -r -s i -l import -d "Initialize with a formatted password file"

# cithare show
complete -c cithare -n "__fish_seen_subcommand_from show" -f -l show-password -d "Show plain passwords"
complete -c cithare -n "__fish_seen_subcommand_from show" -f -r -s d -l display-time -d "Show passwords for <duration>"
