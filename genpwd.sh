#!/bin/bash

# Function to display help message
display_help() {
    echo "Usage: ${0##*/} [-n number_of_passwords] [-l min_word_length] [-r max_retries] [--regen]"
    echo "Generate random passwords based on words and numbers."
    echo "Options:"
    echo "  -n  Number of passwords to generate (default is 1)."
    echo "  -l  Minimum length of the words (default is 4)."
    echo "  -m  Maximum length of the words (default is the minimum length + 3)."
    echo "  -r  Maximum number of retries for each word (default is 30)."
    echo "  --regen  Download the latest words file."
}

# Initialize default values
times_to_run=1
min_word_length=4
max_word_length=$((min_word_length + 3))
max_retries=30
regen=false
storage_path="$HOME/.config/genpwd"
words_file="$storage_path/genpwd-words.txt"


# Check for --regen option among other arguments
for arg in "$@"; do
  if [ "$arg" == "--regen" ]; then
    regen=true
    break
  fi
done

# If words file doesnt exist, download it using wget
if ! [ -r $words_file ]; then
    # Create the directory if it doesn't exist
    if [ ! -d "$storage_path" ]; then
      mkdir -p "$storage_path"
    fi
    echo "Downloading words file..."
    wget -O "$words_file" "https://raw.githubusercontent.com/first20hours/google-10000-english/master/google-10000-english-no-swears.txt"
    if [ $? -ne 0 ]; then
        echo "Download failed."
        exit 1
    fi
    echo "Download complete."
    exit 0
fi

# If --regen is true, download new words file using wget
if [ "$regen" = true ]; then
    echo "Downloading new words file..."
    wget -O "$words_file" "https://raw.githubusercontent.com/first20hours/google-10000-english/master/google-10000-english-no-swears.txt"
    if [ $? -ne 0 ]; then
        echo "Download failed."
        exit 1
    fi
    echo "Download complete."
    exit 0
fi

# Exit after completing --regen
if [ "$regen" = true ]; then
    exit 0
fi

# Parse command line arguments for standard flags
while getopts ":n:l:m:r:h" opt; do
  case $opt in
    n) 
      if [[ "$OPTARG" =~ ^[0-9]+$ ]]; then
        times_to_run="$OPTARG"
      else
        echo "Error: -n requires a numeric argument." >&2
        exit 1
      fi
      ;;
    l) 
      if [[ "$OPTARG" =~ ^[0-9]+$ ]]; then
        min_word_length="$OPTARG"
      else
        echo "Error: -l requires a numeric argument." >&2
        exit 1
      fi
      ;;
    m) 
      if [[ "$OPTARG" =~ ^[0-9]+$ ]]; then
        max_word_length="$OPTARG"
      else
        echo "Error: -m requires a numeric argument." >&2
        exit 1
      fi
      ;;
    r) 
      if [[ "$OPTARG" =~ ^[0-9]+$ ]]; then
        max_retries="$OPTARG"
      else
        echo "Error: -r requires a numeric argument." >&2
        exit 1
      fi
      ;;
    h) display_help; exit 0;;
    \?) echo "Invalid option -$OPTARG" >&2; exit 1;;
  esac
done

# Check the option validity
if [ "$min_word_length" -gt "$max_word_length" ]; then
    echo "Invalid option: Minimum word length ("$min_word_length") must be less or equal to than Maximum word length ("$max_word_length")." >&2; exit 1
fi
if [ $max_retries -le 0 ]; then
    echo "Invalid option: Minimum retries ("$max_retries") must be greater than 0." >&2; exit 1
fi

# Function to get a random word from the words file
get_word_from_file() {
    local word
    local retry_count=0

    while [ "$retry_count" -lt "$max_retries" ]; do
        # Get a random word from the array
        word="${word_array[$(shuf -i 0-$(( ${#word_array[@]} - 1 )) -n 1)]}"
        
        # Check the word length and return
        if [ "${#word}" -ge "$min_word_length" ] && [ "${#word}" -le "$max_word_length" ]; then
            echo "$word"
            return 0
        fi

        retry_count="$((retry_count + 1))"
    done
    echo "Error: Could not find a suitable word after "$max_retries" retries." >&2
    exit 1
}

# Fetch all words from the words file into an array
mapfile -t word_array < "$words_file"

# Check if the words array is empty
if [ "${#word_array[@]}" -eq 0 ]; then
    echo "Error: Words file is empty or not accessible." >&2
    exit 1
fi

# Loop to run the script the specified number of times
for ((i=1; i<=times_to_run; i++)); do

#     # Generate three random words
#     word1=$(get_word_from_file)
#     word2=$(get_word_from_file)
#     word3=$(get_word_from_file)
# 
#     # Generate two random numbers
#     number=$(shuf -i 10-999 -n 1)
#     number2=$(shuf -i 10-999 -n 1)
# 
#     # Echo the random string
#     echo ""
#     echo "$word1$number$word2$number2$word3"
#     echo ""

    # Generate two random words
    word1=$(get_word_from_file)
    word2=$(get_word_from_file)

    # Generate a random number
    number=$(shuf -i 10-999 -n 1)

    # Echo the random string
    echo ""
    echo "$word1$number$word2"
    echo ""
done
exit 0