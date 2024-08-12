#!/bin/bash

# Función para mostrar ayuda
function show_help {
	echo "Uso: $0"
}

# Determinar el directorio de father_project
script_dir=$(dirname "$(realpath "$0")")
scaffold_project=$(dirname "$script_dir")
father_project=$(dirname "$scaffold_project")

# Comprobar si father_project es un repositorio git
if [ ! -d "$father_project/.git" ]; then
	echo "El directorio padre ($father_project) no es un repositorio git."
	exit 1
fi

# Cambiar al directorio father_project
cd "$father_project"

# Comprobar si la rama metadata-branch existe y cambiar a ella
if git show-ref --quiet refs/heads/metadata-branch; then
	git checkout metadata-branch
else
	echo "La rama 'metadata-branch' no existe en el repositorio father_project."
	exit 1
fi

# Leer el nombre del proyecto desde metadata.json
if [ ! -f metadata.json ]; then
	echo "El archivo metadata.json no existe en la rama metadata-branch."
	exit 1
fi

project_name=$(jq -r '.lang.en.name' metadata.json)

remote_url=$(git remote get-url origin)
repo_path=$(echo "$remote_url" | sed -e 's/^git@github.com://' -e 's/\.git$//' -e 's/:/\//')
project_git_url="https://github.com/$repo_path/issues/new"

year=$(date +%Y)
holder="Israel López"

if [ -z "$project_name" ]; then
	echo "No se pudo leer el nombre del proyecto desde metadata.json."
	exit 1
fi

# Cambiar de nuevo a la rama principal (supongamos que es main, cambiar si es diferente)
git checkout main

# Función para reemplazar [__PROJECT_NAME__] en un archivo
replace_project_name() {
	local src_file=$1
	local dest_file=$2
	sed "s/\[__PROJECT_NAME__\]/$project_name/g" "$src_file" >"$dest_file"
}

# Función para reemplazar [__PROJECT_GIT_URL__] en un archivo
replace_project_git_name() {
	local src_file=$1
	local dest_file=$2
	sed "s/\[__PROJECT_GIT_URL__\]/$project_git_url/g" "$src_file" >"$dest_file"
}

# Función para reemplazar [__YEAR__] en un archivo
replace_project_year() {
	local src_file=$1
	local dest_file=$2
	sed "s/\[__YEAR__\]/$year/g" "$src_file" >"$dest_file"
}

# Función para reemplazar [__COPYRIGHT_HOLDER__] en un archivo
replace_project_holder() {
	local src_file=$1
	local dest_file=$2
	sed "s/\[__COPYRIGHT_HOLDER__\]/$holder/g" "$src_file" >"$dest_file"
}

# Directorio de los templates en scaffold_project
files_dir="$scaffold_project/files"

# Crear archivos en father_project

# Copiar LICENSE si no existe
if [ ! -f LICENSE ]; then
	echo "Creando LICENSE"
	replace_project_year "$files_dir/LICENSE" "LICENSE"
	replace_prject_holder "LICENSE" "LICENSE"
else
	echo "El archivo template LICENSE no existe en $files_dir."
fi

# Copiar y reemplazar [__PROJECT_NAME__] en CODE_OF_CONDUCT.md
if [ -f "$files_dir/CODE_OF_CONDUCT.md" ]; then
	echo "Creando CODE_OF_CONDUCT.md"
	replace_project_name "$files_dir/CODE_OF_CONDUCT.md" "CODE_OF_CONDUCT.md"
else
	echo "El archivo template CODE_OF_CONDUCT.md no existe en $files_dir."
fi

# Copiar y reemplazar [__PROJECT_NAME__] en CONTRIBUTING.md
if [ -f "$files_dir/CONTRIBUTING.md" ]; then
	echo "Creando CONTRIBUTING.md"
	replace_project_name "$files_dir/CONTRIBUTING.md" "CONTRIBUTING.md"
	replace_project_git_name "CONTRIBUTING.md" "CONTRIBUTING.md"
else
	echo "El archivo template CONTRIBUTING.md no existe en $files_dir."
fi

# Crear un README.md básico si no existe
if [ ! -f README.md ]; then
	echo "Creando README.md"
	echo "# $project_name" >README.md
	echo "" >>README.md
	echo "## Descripción" >>README.md
	echo "Este proyecto es $project_name." >>README.md
fi

# Añadir y commitear los archivos en father_project
git add LICENSE CODE_OF_CONDUCT.md CONTRIBUTING.md README.md
git commit -m "Add mandatory files: LICENSE, CODE_OF_CONDUCT.md, CONTRIBUTING.md, README.md"

# Avisar al usuario
echo "Se han creado los archivos obligatorios en father_project."