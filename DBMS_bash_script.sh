/#! /usr/bin/bash

if [ -d dbms ]; then
	cd dbms
else
	mkdir dbms
	cd dbms
fi

# Function to validate user inputs 
validate_input() {

  # Reserved keywords list
  reserved_keywords=("select" "from" "where" "insert" "update" "delete" "drop" "alter" "create")

  local db_name="$1"  # Get the input database name
  db_name="${db_name,,}"  # Convert database name into lowercase

  
  if [[ $# -gt 1 ]]; then
    echo "=================================="
    echo "Error: Name cannot contain spaces."
    echo "=================================="
    return 1
  fi
    
  # Check if the name is empty or only contains spaces
  if [[ -z "$db_name" || "$db_name" =~ ^[[:space:]]*$ ]]; then
    echo "==========================================="
    echo "Error: Name cannot be empty or only spaces."
    echo "==========================================="
    return 1
  fi

  # Check if the name contains any special characters (only letters, numbers, and underscores allowed)
  if [[ ! "$db_name" =~ ^[a-zA-Z0-9_]+$ ]]; then
    echo "=============================================================="
    echo "Error: Name can only contain letters, numbers, or underscores."
    echo "=============================================================="
    return 1
  fi
  
  # Check if the name starts with a number
  if [[ "$db_name" =~ ^[0-9] ]]; then
    echo "======================================="
    echo "Error: Name cannot start with a number."
    echo "======================================="
    return 1
  fi

  # Check if the name matches any reserved keywords
  for keyword in "${reserved_keywords[@]}"; do
    if [[ "$db_name" == "$keyword" ]]; then
      echo "============================================"
      echo "Error: Name cannot match a reserved keyword."
      echo "============================================"
      return 1
    fi
  done

  # Check the length of the name
  if [[ ${#db_name} -gt 64 ]]; then
    echo "========================================"
    echo "Error: Name cannot exceed 64 characters."
    echo "========================================"
    return 1
  fi

  # If all tests pass
  return 0
}


create_db(){
    read -p "Enter the database name: " db_name
    
    validate_input $db_name
    
    # Validate database name
    if [[ $? -eq 1 ]]; then
    	return
    # Check for uniqueness (-e means exist)
    elif [[ -e "$db_name" ]]; then
	    echo "================================================"
	    echo "Error: Name conflicts with an existing database."
	    echo "================================================"
	    return
    else 
    	mkdir "$db_name"  # Create the directory with the database name
    	echo "========================================="
        echo "Database '$db_name' created successfully!"
        echo "========================================="
    fi

}

list_dbs(){
	
	# Check if the directory contains any subdirectories
	if [ $(ls -p $PWD | grep / | wc -l) -gt 0 ]; then
	# If there are subdirectories, list them

		echo "--------------------------------------------"
		ls -p $PWD | grep / | sed 's/\/$//' 
		echo "--------------------------------------------"
	else
	# If there are no subdirectories (empty or only files), print "no databases"

  		echo "=========================="
  		echo "no databases"
  		echo "=========================="
	fi
}

drop_db(){
	
	read -p "Enter the database name you want to drop: " db_name
	
	validate_input $db_name
        # Validate database name
    	if [[ $? -eq 1 ]]; then
    		return
    	# Check if database exsits 
	elif [[ ! -d $db_name ]]; then
		echo "----------------------"
		echo "No such database found"
		echo "----------------------"
		return
	else
		rm -r $db_name
		echo "------------------------------"
		echo "Database dropped successfully!"
		echo "------------------------------"
	fi

}

connect_db(){

	read -p "Enter the database name you want to connect to: " db_name
	
	validate_input $db_name
	
	# Validate database name
    	if [[ $? -eq 1 ]]; then
    		return
    	# Check if database exsits 
	elif [[ ! -d $db_name ]]; then
		echo "----------------------"
		echo "No such database found"
		echo "----------------------"
		return
	else 
		cd ~/dbms/$db_name
			
		#export db_name
		db_operations_menu $db_name
	fi
}

db_operations_menu(){

	echo $PWD
	echo "---------------------------"
	
	db_name="$1"
	
	while true; do
	
	echo "Database $db_name menu: "
	echo "1. Create Table"
        echo "2. List Tables"
        echo "3. Drop Table"
        echo "4. Insert into Table"
        echo "5. Select From Table"
        echo "6. Delete From Table"
        echo "7. Update Table"
        echo "8. Return to Main Menu"
        
        read -p "Enter your choice: " choice
        
        case $choice in
            1) create_table ;;
            2) list_tables ;;
            3) drop_table ;;
            4) insert_into_table ;;
            5) select_from_table ;;
            6) delete_from_table ;;
            7) update_table ;;
            8) cd ..
            	echo "---------------------------"
            	break ;;  # Exit to the main menu
            *) echo "Invalid option. Please try again." ;;
        esac
    done
	
}

create_table(){

	read -p "Please enter the table name: " table_name
	
	validate_input $table_name
    
	# Validate database name
	if [[ $? -eq 1 ]]; then
		return
	# Check for uniqueness (-e means exist)
	elif [[ -e "$table_name" ]]; then
		echo "====================================="
		echo "Table " $table_name " alraedy exists."
		echo "====================================="s
	return
	fi
	
	touch $table_name
	touch .$table_name
	
	read -p "Enter the number of columns: " column_num
	
	if [[ ! $column_num =~ ^[0-9]+$ ]]; then
		echo "========================================"
		echo "Column number must contain only numbers."
		echo "========================================"
		rm $table_name
		rm .$table_name
		return
	elif [[ $column_num -eq 0 ]]; then
		echo "=============================="
		echo "Column number can not be zero."
		echo "=============================="
		rm $table_name
		rm .$table_name
		return
	
	fi
	
	max_columns=50
	if ((column_num>max_columns)); then
		echo "=========================================================="
		echo "Error: Column number can not exceed "$max_columns" column."
		echo "=========================================================="
		rm $table_name
		rm .$table_name
		return
	fi
	
	columns=()
	sep=":"
	rSep=","
	pKey=""
	meta_data=""
	
	for ((i=1;i<=$column_num;i++)); do
	
		read -p "Please enter the column name: " column_name
		validate_input $column_name
		
		if [[ $? -eq 1 ]]; then
			echo "Invalid column name, please tryn again!"
			echo "======================================="
			((i--))
			continue
		fi
		
		if [[ " ${columns[@]} " =~ " ${column_name} " ]]; then
			echo "Column name"$column_name"already exists, please try again!"
			echo "============================================================"
			((i--))
			continue	
		fi
		columns+="$column_name"
		
	echo "Choose the column data type: "
	while true; do
	    select option in "Int" "String"; do
		case $option in
		    "Int")
		    	col_type="int"
		        break 2  # Exit both the select and while loops
		        ;;
		    "String")
		    	col_type="str"
		        break 2  # Exit both the select and while loops
		        ;;
		    *)
		        echo "Invalid column type. Please choose 1 or 2."
		        break  # Exit the select menu and re-display it
		        ;;
		esac
	    done
	done
	
	if [[ $pKey == "" ]]; then
	      echo -e "Do yo want to make this column PrimaryKey ? "
	      select var in "yes" "no"
	      do
		case $var in
		  yes ) pKey="PK";
		  	if [[ $i -eq 1 ]]; then
		  		temp=$column_name$sep$col_type$sep$pKey
		  		temp="${temp%:}"
		  		meta_data+=$temp
		  	else
		  		temp=$rSep$column_name$sep$col_type$sep$pKey
		  		temp="${temp%:}"
				meta_data+=$temp
			fi
			break;;
		  no )
		  	if [[ $i -eq 1 ]]; then
		  		temp=$column_name$sep$col_type""
		  		temp="${temp%:}"
		  		meta_data+=$temp
		  	else
		  		temp=$rSep$column_name$sep$col_type""
		  		temp="${temp%:}"
				meta_data+=$temp
			fi
			break;;
		  * ) echo "Wrong Choice" ;;
		esac
	      done
	  else
	 	if [[ $i -eq 1 ]]; then
	 		temp=$column_name$sep$col_type""
	 		temp="${temp%:}"
	 		meta_data+=$temp
	 	else
	 		temp=$rSep$column_name$sep$col_type""
	 		temp="${temp%:}"
	        	meta_data+=$temp
	        fi
	fi
	done
	
	meta_data="${meta_data%:}" #Remove the trailing colon if any

	echo $meta_data >> .$table_name
	
	echo "========================================="
	echo "Table "$table_name" created successfully!"
	echo "========================================="
	 
}

list_tables() {
    echo "===================="

    # List files in the current directory
    files=$(ls -p | grep -v '/')

    # Check if there are any files
    if [[ -z "$files" ]]; then
        echo "No tables found."
    else
        echo "$files"
    fi

    echo "===================="
}


drop_table(){

	read -p "Enter the table name you want to drop: " table_name
	
	validate_input $table_name
	
	if [[ $? -eq 1 ]]; then
		return
	# Check for uniqueness (-e means exist)
	elif [[ ! -e "$table_name" ]]; then
		echo "====================================="
		echo "Table "$table_name" does not exist."
		echo "====================================="
	return
	fi
	
	rm $table_name .$table_name
	if [[ $? == 0 ]]; then
	    echo "========================================"
	    echo "Table "$table_name" Dropped Successfully"
	    echo "========================================"
	else
	    echo "================================"	
	    echo "Error Dropping Table $table_name"
	    echo "================================"
	    return
	fi	

}

insert_into_table(){

	read -p "Enter the table name: " table_name
	
	validate_input $table_name
	
	if [[ $? -eq 1 ]]; then
		return
	elif [[ ! -f $table_name ]]; then
		echo "================================="
		echo "Table $table_name does not exist."
		echo "================================="
		return
	elif [[ ! -f .$table_name ]]; then
		echo "==============================================="
		echo "Meta data for table $table_name does not exsit."
		echo "==============================================="
		return
	else
		insertRow $table_name
	fi	

}

# Description: Function to insert a row into a table with validation

# Function to check if the input is an integer and its length <= 6
function checkInt() {
    local re='^-?[0-9]+$'
    
    if ! [[ "$1" =~ $re ]]; then
        echo "Invalid pattern for Integer."
        return 1
    fi
	
    # Check if input length exceeds 6 digits
    if (( ${#1} > 6 )); then
    	echo "Integer input can not exceed 6 digits."
        return 1
    fi

    # Check if input matches the integer pattern
    
    return 0
}


# Function to check if the input is a string and its length <= 64
function checkString() {
    local re='^[[:print:]]+$'

    # Check if input matches the string pattern
    if ! [[ "$1" =~ $re ]]; then
        echo "Input does not match alphabetic pattern."
        return 1
    fi

    
    # Check if input length exceeds 30 characters
    if (( ${#1} > 256 )); then
    	echo "String can not exceed 256 characters."
        return 1
    fi


    return 0
}

# Function to extract default value from metadata
function getDefaultValue() {
    local metadata="$1"
    if [[ "$metadata" == DEFAULT= ]]; then
        echo "$metadata" | grep -oP 'DEFAULT=\K.*'
    else
        echo ""
    fi
}

# Function to parse metadata
function parseMetadata() {
    local table="$1"
    metadata=$(cat ".$table" | tr ',' '\n')
    ColsName=()
    ColsDataTypes=()
    ColsConstraints=()
    ColsDefaults=()

    for column in $metadata; do
        ColsName+=("$(echo $column | cut -d':' -f1)")
        ColsDataTypes+=("$(echo $column | cut -d':' -f2)")
        ColsConstraints+=("$(echo $column | cut -d':' -f3)")
        ColsDefaults+=("$(getDefaultValue "$column")")
    done
}

function insertRow() {
    local table="$1"

    # Parse metadata
    parseMetadata "$table"

    # Initialize an empty row for insertion
    local output=""

    # Loop through each column to get user input
    for i in "${!ColsName[@]}"; do
        while true; do
            # Prompt user for input with column details
            read -p "Please enter value for ${ColsName[i]} (${ColsDataTypes[i]}): " input

            # Handle empty input
            if [ -z "$input" ]; then
                if [ "${ColsConstraints[i]}" == "PK" ]; then
                    echo "Value for ${ColsName[i]} cannot be empty. Please try again."
                    continue
                elif [ -n "${ColsDefaults[i]}" ]; then
                    input="${ColsDefaults[i]}"
                    echo "Using default value: $input"
                else
                    input="NULL"
                fi
            fi


	# Validate data type
                if [ "${ColsDataTypes[i]}" == "int" ]; then
                    checkInt "$input"
                    if [[ $? -ne 0 ]]; then
                    	continue
                    fi  
                elif [ "${ColsDataTypes[i]}" == "str" ]; then
                    checkString "$input"
                    if [[ $? -ne 0 ]]; then
                    	continue
                    fi
                else
                    echo "Unknown data type for column ${ColsName[i]}."
                    continue
                fi
         

            # Check for primary key uniqueness
            if [ "${ColsConstraints[i]}" == "PK" ]; then
                if cut -d':' -f$((i + 1)) "./$table" | grep -q "^$input$"; then
                    echo "Value for ${ColsName[i]} must be unique as it is a primary key. Please try again."
                    continue
                fi
            fi

            # Append to the output string with proper quoting
		if [ $i -ne $((${#ColsName[@]} - 1)) ]; then
		    output+="${input//:/ }:"
		else
		    output+="${input//:/ }"
		fi
		break
	    done
    done

    # Write the new row to the table file
    echo "$output" >> "$table"
    echo "-----------------------------------------------------------------------"
    echo "Row inserted Successfully :)"
    echo "-----------------------------------------------------------------------"
}

select_from_table(){

	read -p "Enter the table name: " table_name
 	
 	validate_input $table_name
 	
 	if [[ $? -eq 1 ]]; then
		return
	elif [[ ! -f $table_name ]]; then
		echo "================================="
		echo "Table $table_name does not exist."
		echo "================================="
		return
	elif [[ ! -f .$table_name ]]; then
		echo "==============================================="
		echo "Meta data for table $table_name does not exsit."
		echo "==============================================="
		return
	fi
	
	
	echo "-----------------Select Menu---------------------"
	echo "| 1. Select All Columns of a Table              |"
  	echo "| 2. Select Specific Column from a Table        |"
  	echo "| 3. Select From Table under condition          |"
 	echo "| 4. Back To Tables Menu                        |"
 	read -p "Enter your choice: " choice
 	
 	case $choice in 
 		1) select_all $table_name ;;
 		2) select_spec $table_name ;;
 		3) select_cond $table_name ;;
 		4) return ;;
 		*) echo "Invalid choice"
 	esac

}

select_all(){
    # Read metadata and extract column names
    metadata=$(cat ".$1" | tr ',' '\n')
    ColsName=()

    for column in $metadata; do
        ColsName+=("$(echo $column | cut -d':' -f1)")
    done

    # Define column width (adjust as needed for your data)
    col_width=31

    # Print a separator line
    printf '%s\n' "$(printf '%0.s-' {1..80})"

    # Print column headers with proper spacing
    for col in "${ColsName[@]}"; do
        printf "%-*s" "$col_width" "$col"
    done
    echo

    # Print another separator line
    printf '%s\n' "$(printf '%0.s-' {1..80})"

    # Read and display the data from the file with proper spacing
    while IFS=':' read -r -a row; do
        for value in "${row[@]}"; do
            printf "%-*s" "$col_width" "$value"
        done
        echo
    done < "$1"

    # Print a final separator line
    printf '%s\n' "$(printf '%0.s-' {1..80})"
}

select_spec() {

    metadata=$(cat ".$1" | tr ',' '\n')
    ColsName=()
    selected_columns=()

    for column in $metadata; do
        ColsName+=("$(echo $column | cut -d':' -f1)")
    done

    echo "Available columns: *" ${ColsName[@]} "*"

    while true; do
        read -p "Enter a column name to select or done to finish: " col_name
        validate_input "$col_name"
        if [[ $? -eq 1 ]]; then
            continue
        fi

        if [[ "$col_name" == "done" ]]; then
            echo "Column selection finished."
            break
        fi

        if [[ ! " ${ColsName[*]} " =~ " $col_name " ]]; then
            echo "Error: Column '$col_name' does not exist in the table."
        elif [[ " ${selected_columns[*]} " =~ " $col_name " ]]; then
            echo "Column '$col_name' is already selected."
        else
            # Add the valid column to the selected list
            selected_columns+=("$col_name")
            echo "Column '$col_name' added to the selection."
        fi
    done

    if [[ ${#selected_columns[@]} -eq 0 ]]; then
        echo "No columns selected."
        return
    fi

    data_file=$1  # File containing the table data

    # Create an array to store the indices of the selected columns
    selected_indices=()
    for selected in "${selected_columns[@]}"; do
        for i in "${!ColsName[@]}"; do
            if [[ "${ColsName[i]}" == "$selected" ]]; then
                selected_indices+=("$i")
                break
            fi
        done
    done

    # Define the static column width
    col_width=31

    # Print the selected column headers with fixed width
    for idx in "${selected_indices[@]}"; do
        printf "%-${col_width}s" "${ColsName[idx]}"
    done
    echo

    # Print a separator line
    printf '%0.s-' {1..80}
    echo

    # Read the data file and display only the selected columns
    while IFS=':' read -r -a row; do
        # Skip empty rows
        is_empty=true
        for value in "${row[@]}"; do
            if [[ -n "$value" ]]; then
                is_empty=false
                break
            fi
        done
        if $is_empty; then
            continue
        fi

        for idx in "${selected_indices[@]}"; do
            printf "%-${col_width}s" "${row[idx]}"
        done
        echo
    done < "$data_file"

    # Print a final separator line
    printf '%0.s-' {1..80}
    echo
}


select_cond(){

    # Read metadata and extract column names
    metadata=$(cat ".$1" | tr ',' '\n')
    ColsName=()
    for column in $metadata; do
        ColsName+=("$(echo "$column" | cut -d':' -f1)")
    done

    # Ask the user for the field name
    echo "Available fields: ${ColsName[*]}"
    read -p "Enter the field name to filter by: " field_name
    
    validate_input $field_name
    
    	if [[ $? -eq 1 ]]; then
		return;
	fi

    # Check if the field name exists
    field_index=-1
    for i in "${!ColsName[@]}"; do
        if [[ "${ColsName[i]}" == "$field_name" ]]; then
            field_index=$i
            break
        fi
    done

    if [[ $field_index -eq -1 ]]; then
    	echo "==============================================="
        echo "Error: Field name '$field_name' does not exist."
        echo "==============================================="
        return
    fi

    # Ask the user for the value to match
    read -p "Enter the value to match: " match_value
    
    validate_input $match_value
    
    	if [[ $? -eq 1 ]]; then
		break;
	fi

    # Define column width (adjust as needed for your data)
    col_width=31

    # Print a separator line
    printf '%s\n' "$(printf '%0.s-' {1..80})"

    # Print column headers with proper spacing
    for col in "${ColsName[@]}"; do
        printf "%-*s" "$col_width" "$col"
    done
    echo

    # Print another separator line
    printf '%s\n' "$(printf '%0.s-' {1..80})"

    # Read and display rows that match the condition
    while IFS=':' read -r -a row; do
        # Skip empty rows
        is_empty=true
        for value in "${row[@]}"; do
            if [[ -n "$value" ]]; then
                is_empty=false
                break
            fi
        done
        if $is_empty; then
            continue
        fi

        # Check if the row matches the condition
        if [[ "${row[field_index]}" == "$match_value" ]]; then
            for value in "${row[@]}"; do
                printf "%-*s" "$col_width" "$value"
            done
            echo
        fi
    done < "$1"

    # Print a final separator line
    printf '%s\n' "$(printf '%0.s-' {1..80})"
    
}

delete_from_table(){

	read -p "Enter the table name: " table_name
 	
 	validate_input $table_name
 	
 	if [[ $? -eq 1 ]]; then
		return
	elif [[ ! -f $table_name ]]; then
		echo "================================="
		echo "Table $table_name does not exist."
		echo "================================="
		return
	elif [[ ! -f .$table_name ]]; then
		echo "==============================================="
		echo "Meta data for table $table_name does not exsit."
		echo "==============================================="
		return
	fi
	
	    # Read metadata and extract column names
	    metadata=$(cat ".$table_name" | tr ',' '\n')
	    ColsName=()
	    for column in $metadata; do
		ColsName+=("$(echo "$column" | cut -d':' -f1)")
	    done
	    
	echo "Available fields: ${ColsName[*]}"
    	read -p "Enter the field name to match for deletion: " field_name
    	
    	validate_input $field_name
    	if [[ $? -eq 1 ]]; then
    		return
    	fi
    	
    	    # Check if the field name exists
	    field_index=-1
	    for i in "${!ColsName[@]}"; do
		if [[ "${ColsName[i]}" == "$field_name" ]]; then
		    field_index=$i
		    break
		fi
	    done

	    if [[ $field_index -eq -1 ]]; then
	    	echo "==============================================="
		echo "Error: Field name '$field_name' does not exist."
		echo "==============================================="
		return
	    fi
	    
	    # Ask the user for the value to match
	    read -p "Enter the value to match for deletion: " match_value

	    # Create a temporary file to store rows that do not match the condition
	    temp_file=$(mktemp)

	    # Flag to track if any row was deleted
	    deleted_flag=false
	    
	        # Read the data file line by line
	    while IFS=':' read -r -a row; do
		# Skip rows that are empty
		is_empty=true
		for value in "${row[@]}"; do
		    if [[ -n "$value" ]]; then
		        is_empty=false
		        break
		    fi
		done
		if $is_empty; then
		    continue
		fi
		# Check if the row matches the condition
		if [[ "${row[field_index]}" == "$match_value" ]]; then
		    deleted_flag=true
		    echo "==========================================="
		    echo "Row deleted: ${row[*]}"
		    echo "==========================================="
		    continue  # Skip adding this row to the temp file
		fi

		# Write the row to the temporary file
		echo "${row[*]}" | tr ' ' ':' >> "$temp_file"
	    	done < "$table_name"
	    	
	    # If no rows were deleted, display a message
	    if ! $deleted_flag; then
	    	echo "=============================="
		echo "No rows matched the condition."
		echo "=============================="
	    fi

	    # Replace the original data file with the updated file
	    mv "$temp_file" "$table_name"
	    echo "Deletion complete."

}
###################################
##laaaastt update
update_table() {
    # Request table name
    while true; do
        read -p "Enter the table name: " table_name

        # Check if the table exists
        if [[ ! -f "$table_name" ]]; then
            echo "Error: Table '$table_name' does not exist. Please enter a valid table name."
        else
            break
        fi
    done

    # Check for the metadata file
    metadata_file=".$table_name"
    if [[ ! -f "$metadata_file" ]]; then
        echo "Error: Metadata file '$metadata_file' does not exist."
        return 1
    fi

    # Read the metadata (column names and types)
    local metadata=$(cat "$metadata_file")
    IFS=',' read -ra metadata_columns <<< "$metadata"

    # Extract column names and types from metadata
    metadata_names=()
    metadata_types=()
    for col in "${metadata_columns[@]}"; do
        metadata_names+=("$(echo "$col" | cut -d':' -f1)")
        metadata_types+=("$(echo "$col" | cut -d':' -f2)")
    done
    echo "Available columns:"
    for col in "${metadata_names[@]}"; do
        echo "$col"
    done

    # Request column for the condition
    while true; do
        read -p "Enter the column name for the condition: " condition_col
        if [[ ! " ${metadata_names[*]} " =~ " ${condition_col} " ]]; then
            echo "Error: Column '$condition_col' does not exist in the metadata."
        else
            # Get the data type of the condition column
            condition_metadata=$(echo "$metadata" | tr ',' '\n' | grep "^$condition_col:")
            condition_col_type=$(echo "$condition_metadata" | cut -d':' -f2)

            while true; do
                read -p "Enter the value for the condition: " condition_val

                # Validate the condition value based on its type
                if [[ "$condition_col_type" == "int" && ! "$condition_val" =~ ^[0-9]+$ ]]; then
                    echo "Error: Value '$condition_val' is invalid for column '$condition_col' (expected integer)."
                elif [[ "$condition_col_type" == "str" && -z "$condition_val" ]]; then
                    echo "Error: Value cannot be empty for column '$condition_col' (expected string)."
                else
                    # Check if the value exists in the table
                    if ! grep -qw "$condition_val" "$table_name"; then
                        echo "Error: Value '$condition_val' does not exist in the table in column '$condition_col'."
                    else
                      break
                    fi
                fi
            done
            break
        fi
    done

   
  
    while true; do
        read -p "Enter the column name to update: " update_col
        if [[ ! " ${metadata_names[*]} " =~ " ${update_col} " ]]; then
            echo "Error: Column '$update_col' does not exist in the metadata."
            continue
        fi
        
       
        # If the column is the PK 
        
        primary_key=$(echo "$metadata" | tr ',' '\n' | grep ":PK" | cut -d':' -f1)

        if [[ "$update_col" == "$primary_key" ]]; then

            read -p "Enter the new value for the '$update_col' column: " new_value

            # Validate that the new value is not empty
            if [[ -z "$new_value" ]]; then
                echo "Error: The new value for '$update_col' cannot be null."
                continue
            fi
              # Check if the value already exists (Primary Key uniqueness)
            if grep -q "^$new_value:" "$table_name"; then
                echo "Error: The value '$new_value' already exists in the '$primary_key' column. The primary key must be unique."
                continue
            fi
        else
            read -p "Enter the new value for the '$update_col' column: " new_value
        fi
 
            # Type validation for other columns
            update_metadata=$(echo "$metadata" | tr ',' '\n' | grep "^$update_col:")
            update_col_type=$(echo "$update_metadata" | cut -d':' -f2)

            if [[ "$update_col_type" == "int" && ! "$new_value" =~ ^[0-9]+$ ]]; then
                echo "Error: Value '$new_value' is invalid for column '$update_col' (expected integer)."
                continue
            elif [[ "$update_col_type" == "str" && -z "$new_value" ]]; then
                echo "Error: Value for '$update_col' cannot be empty (expected string)."
                continue
            # Prevent colon (:) in string values
            elif [[ "$update_col_type" == "str" && "$new_value" =~ ":" ]]; then
                echo "Error: Colons (:) are not allowed in string values for column '$update_col'. Please enter a valid string without colons."
                continue
    
            
            fi
        
        break
    done

    # Find the indices for the condition and update columns
    condition_index=-1
    update_index=-1
    for i in "${!metadata_names[@]}"; do
        if [[ "${metadata_names[$i]}" == "$condition_col" ]]; then
            condition_index=$i
        fi
        if [[ "${metadata_names[$i]}" == "$update_col" ]]; then
            update_index=$i
        fi
    done

    # Check if column indices were found
    if [[ $condition_index -eq -1 || $update_index -eq -1 ]]; then
        echo "Error: Failed to locate column indices in the metadata."
        return 1
    fi

    # Extract column type from metadata
    update_metadata=$(echo "$metadata" | tr ',' '\n' | grep "^$update_col:")
    update_col_type=$(echo "$update_metadata" | cut -d':' -f2)

    # Validate data type of the updated value
    if [[ "$update_col_type" == "int" && ! "$new_value" =~ ^[0-9]+$ ]]; then
        echo "Error: Value '$new_value' is invalid for column '$update_col' (expected integer)."
        return 1
    elif [[ "$update_col_type" == "str" && -z "$new_value" ]]; then
        echo "Error: Value '$new_value' is invalid for column '$update_col' (expected string)."
        return 1
    fi

    # Perform the update
     tmp_file="${table_name}.tmp"

    awk -F':' -v OFS=':' -v cond_idx="$((condition_index + 1))" -v upd_idx="$((update_index + 1))" -v cond_val="$condition_val" -v upd_val="$new_value" '
        {
            if ($cond_idx == cond_val) {
                $upd_idx = upd_val
            }
            print
        }
    ' "$table_name" > "$tmp_file"

    mv "$tmp_file" "$table_name"

    echo "=============================="	
    echo "Update completed successfully."
    echo "=============================="
}
  
         
         
         
         
#######################################         

echo $PWD
echo "Main menu:"

PS3="Enter your choice: "
while true; do
    echo "1) Create Database"
    echo "2) List Databases"
    echo "3) Connect Database"
    echo "4) Drop Database"
    echo "5) Exit"

    read -p "$PS3" choice

    case $choice in
        1)
            create_db
            ;;
        2)
            list_dbs
            ;;
        3)
            connect_db
            ;;
        4)
            drop_db
            ;;
        5)
            echo "============================="
            echo "Exiting......"
            echo "============================="
            break
            ;;
        *)
            echo "================================="
            echo "Invalid Option. Please try again."
            echo "================================="
            ;;
    esac
done
