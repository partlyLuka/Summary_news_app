import sys
sys.path.append("backend/rtv/add_dates")
sys.path.append("backend/rtv/add_uuid")
sys.path.append("backend/rtv/get_articles")
sys.path.append("backend/rtv/translation")

from add_dates import add_dates
from add_uuid import add_uuid
from data_collection import update
from translate_database import translate

rubrics = ["slovenija", "sport", "svet", "kultura", "zabava-in-slog"]

def main():
    for rubric in rubrics:
        update(rubric, 0, 2, 1.0)
    add_dates()
    add_uuid()
    translate()
    
if __name__ == "__main__":
    main()