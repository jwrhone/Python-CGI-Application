import configparser
from pathlib import Path

#  simplistic and no error handling.
def get_mysql_param(filename='dbconfig.ini', section='mysql'):
    config = configparser.ConfigParser()
    file_path = (Path(__file__).parent / filename).resolve()
    config.read(file_path)   

    return config[section]
