#!/usr/bin/env bash

SCORES_FILE=scores.txt
SCORE=0
RANDOM=4096

menu() {
    echo "Welcome to the True or False Game!"

    while true; do
        print_options

        read option

        case $option in
            0)     
                echo "See you later!"
                break 
                ;;
            1)     
                play_game 
                ;;
            2)     
                display_scores
                ;;
            3)     
                reset_scores
                ;;
            *)     
                echo "Invalid option!" 
                ;;
        esac
    done
}

print_options() {
    options="0. Exit\n1. Play a game\n2. Display scores\n3. Reset scores\nEnter an option:"
    echo -e $options
}

play_game() {
    responses=( "Perfect!" "Awesome!" "You are a genius!" "Wow!" "Wonderful!" )
    
    echo "What is your name?"
    read name

    login

    while true; do
        item=$(curl --cookie cookie.txt http://127.0.0.1:8000/game)
        question=$(echo "$item" | sed 's/.*"question": *"\{0,1\}\([^,"]*\)"\{0,1\}.*/\1/')
        answer=$(echo "$item" | sed 's/.*"answer": *"\{0,1\}\([^,"]*\)"\{0,1\}.*/\1/')

        echo $question
        echo "True or False?"

        read user_answer

        if [ $user_answer = $answer ]; then
            ((SCORE+=10))
            idx=$((RANDOM % 5))
            echo "${responses[$idx]}"
        else
            echo "Wrong answer, sorry!"
            echo "${name} you have $((SCORE/10)) correct answer(s)."
            echo "Your score is ${SCORE} points."
            echo "User: ${name}, Score: ${SCORE}, Date: $(date +%F)" >> $SCORES_FILE
            SCORE=0
            break
        fi
    done
}

display_scores() {
    if [ -e $SCORES_FILE -a -s $SCORES_FILE ]; then
        echo "Player scores"
        cat $SCORES_FILE
    else
        echo "File not found or no scores in it!"
    fi
}

reset_scores() {
    if [ -e $SCORES_FILE -a $SCORES_FILE ]; then
        rm $SCORES_FILE
        echo "File deleted successfully!"
    else
        echo "File not found or no scores in it!"
    fi
}

login() {
    credentials=ID_card.txt
    cookie=cookie.txt

    curl --output $credentials --silent http://127.0.0.1:8000/download/file.txt

    user=$(grep -o '"username": "[^"]*' $credentials | grep -o '[^"]*$')
    pass=$(grep -o '"password": "[^"]*' $credentials | grep -o '[^"]*$')

    curl --silent --cookie-jar $cookie -u $user:$pass http://127.0.0.1:8000/login
}

menu