Pry.config.commands.alias_command 'vim', 'edit'

# require gem with `r`
#
# Examples
#     $ pry -r 'active_support/core_ext'
#     pry(main) > r 'active_support/core_ext'
alias :r :require
