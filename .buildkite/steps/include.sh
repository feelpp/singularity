# Author(s) G. Dollé <dolle@math.unistra.fr>
# Common script.

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/" && pwd )"

CONTAINERS_YAML=${SCRIPT_DIR}/../containers.yml

# List public/private folder girder id.
# comment this avoid building private images
PRIVATE_CONTAINERS_GIRDER_ID_LIST= #`cat "${CONTAINERS_YAML}" | yq -r ".private[].girder_folder_id"`
PUBLIC_CONTAINERS_GIRDER_ID_LIST=`cat "${CONTAINERS_YAML}" | yq -r ".public[].girder_folder_id"`

# Variable that set the EXPR variable used in CONTAINER_LIST.
# comment this avoid building private images
PRIVATE_CONTAINERS_PARSE_EXPR= # 'EXPR=".private[] | select(.girder_folder_id==\"$id\") | .containers[]"'
PUBLIC_CONTAINERS_PARSE_EXPR='EXPR=".public[] | select(.girder_folder_id==\"$id\") | .containers[]"'

# Variable that set the CLIST variable.
CONTAINERS_LIST='CLIST=`cat "${CONTAINERS_YAML}" | yq -r "${EXPR}"`'
