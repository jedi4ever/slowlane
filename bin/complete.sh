_slowlane_itunes_complete()
{
  local cur prev

  COMPREPLY=()
  cur=${COMP_WORDS[COMP_CWORD]}
  prev=${COMP_WORDS[COMP_CWORD-1]}

  if [ $COMP_CWORD -eq 1 ]; then
    COMPREPLY=( $(compgen -W "help team app build tester" -- $cur) )
  elif [ $COMP_CWORD -eq 2 ]; then
    case "$prev" in
      "app")
        COMPREPLY=( $(compgen -W "list help" -- $cur) )
        ;;
      "build")
        COMPREPLY=( $(compgen -W "list help" -- $cur) )
        ;;
      "team")
        COMPREPLY=( $(compgen -W "list help" -- $cur) )
        ;;
      "tester")
        COMPREPLY=( $(compgen -W "list help" -- $cur) )
        ;;
      *)
        ;;
    esac
  elif [ $COMP_CWORD -gt 2 ]; then
    command=${COMP_WORDS[1]}
    subcommand=${COMP_WORDS[2]}
    if [ "$command" == "team" ] && [ "$subcommand" == "list" ]; then
      case "$cur" in
        --*)
          COMPREPLY=( $( compgen -W '--user --password --team' -- $cur ) );;
        *)
          ;;
      esac
    fi
  fi

  return 0
} &&
  complete -F _slowlane_itunes_complete slowlane-itunes
