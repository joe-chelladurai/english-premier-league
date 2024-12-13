#!/bin/bash

# Install dependencies if not present
command -v pup >/dev/null 2>&1 || {
    echo "Installing pup for HTML parsing..."
    curl -L https://github.com/ericchiang/pup/releases/download/v0.4.0/pup_v0.4.0_linux_amd64.zip -o pup.zip
    unzip pup.zip
    chmod +x pup
    sudo mv pup /usr/local/bin/
}

# Create output directory if it doesn't exist
mkdir -p data

# Get current date for the filename
current_date=$(date +%Y-%m-%d)

# Fetch the webpage and extract the table
curl -s "https://www.bbc.com/sport/football/tables" | \
    pup 'table.gs-o-table json{}' | \
    jq -r '.[] | select(.class | contains("gs-o-table")) | 
        .children[1].children[] | 
        [
            (.children[0].text // ""), # Position
            (.children[1].text // ""), # Team
            (.children[2].text // ""), # Played
            (.children[3].text // ""), # Won
            (.children[4].text // ""), # Drawn
            (.children[5].text // ""), # Lost
            (.children[6].text // ""), # GF
            (.children[7].text // ""), # GA
            (.children[8].text // ""), # GD
            (.children[9].text // "")  # Points
        ] | @csv' > "data/premier_league_table_${current_date}.csv"

# Add headers to the CSV
sed -i '1i Position,Team,Played,Won,Drawn,Lost,Goals For,Goals Against,Goal Difference,Points' "data/premier_league_table_${current_date}.csv"

echo "Premier League table has been saved to data/premier_league_table_${current_date}.csv"
