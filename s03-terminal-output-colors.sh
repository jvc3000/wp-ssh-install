RED='\033[0;31m'
BLUE='\033[0;34m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# You can use these ANSI escape codes:
# Black        0;30     Dark Gray     1;30
# Red          0;31     Light Red     1;31
# Green        0;32     Light Green   1;32
# Brown/Orange 0;33     Yellow        1;33
# Blue         0;34     Light Blue    1;34
# Purple       0;35     Light Purple  1;35
# Cyan         0;36     Light Cyan    1;36
# Light Gray   0;37     White         1;37

echo -e "${RED}################################################${NC}"
echo -e "${GREEN}Database Information${NC}"
echo -e "Schema:   ${BLUE}$DB_NAME${NC}"
echo -e "Username: ${BLUE}$DB_USER${NC}"
echo -e "Password: ${BLUE}$DB_PASS${NC}"
echo -e "${RED}################################################${NC}"