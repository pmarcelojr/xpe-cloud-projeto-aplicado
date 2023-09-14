from os import environ
from time import time
import sys
from loguru import logger
import boto3
from botocore.exceptions import ClientError

start_time = time()
logger = get_logger()
FORMAT = '[{extra[data]} |{level}| arquivo: {file}, linha: {line}] {message}'


def lambda_handler(event, context):
    # TODO implement
    glue_client = boto3.client('glue')
    workflow_name = ""
    
    logger.info(f"Evento recebido: {event}")
    logger.info(f"Contexto recebido: {context}")
    logger.info(f"Tempo de execucao: {time() - start_time}")
    
    nome_bucket = event['Records'][0]['s3']['bucket']['name']
    nome_arquivo = event['Records'][0]['s3']['object']['key']
    logger.info(f"Bucket {nome_bucket} - Arquivo: {nome_arquivo}")
    
    if "tbs0mh10" in nome_arquivo:
        workflow_name = "movimento_aplicacao_processado"
    elif "tbs0mh20" in nome_arquivo:
        workflow_name = "movimento_resgate_processado"
        
    if not workflow_name:
        logger.info(f"## Nome do arquivo nao previsto")
    else:
        response = glue_client.start_workflow_run(
                Name=workflow_name,
                RunProperties={
                    'nome_arquivo': nome_arquivo
                }
            )
        logger.info(f"## STARTED GLUE JOB: {workflow_name}")
        logger.info(f"## WORKFLOW RUN ID: {response['RunId']}")
    
    end_time = time()
    tempo_decorrido = end_time - start_time
    logger.info(f"Tempo de execucao: {tempo_decorrido}")
    
    return get_retorno_sucesso()


def get_logger():
    logger.remove()
    logger.add(
        sys.stderr,
        format=FORMAT,
        backtrace=True,
        diagnose=True,
        level='INFO',
    )
    logger_context = logger.patch(
            lambda record: record['extra'].update(
                    data=obter_horario_brasilia_iso8601()
                )
        )
    
    return logger_context


def get_retorno_sucesso():
    return {
        'statusCode': 200,
        'headers': {
            "Content-Type": "application/json"
        },
        "body": {
            "Region": environ['AWS_REGION']
        }
    }
    
    
def get_retorno_erro():
    return {
        'statusCode': 500,
        'headers': {
            "Content-Type": "application/json"
        },
        "body": {
            "Region": environ['AWS_REGION']
        }
    }


def obter_horario_brasilia_iso8601():
    return "2023-09-13"
