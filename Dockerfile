# 1. Base na imagem oficial (versão 15-alpine, por exemplo, ou outra de sua preferência)
FROM postgres:15

# 2. Mudar para o usuário postgres para operações
USER root

# 3. Criar diretório para copiar certificados
RUN mkdir -p /var/lib/postgresql/certs \
    && chown postgres:postgres /var/lib/postgresql/certs \
    && chmod 700 /var/lib/postgresql/certs

# 4. Copiar certificados do host para dentro da imagem
#    -- esses arquivos devem ser montados no build (ver docker-compose)
COPY certs/ca.crt /var/lib/postgresql/certs/root.crt
COPY certs/server.crt /var/lib/postgresql/certs/server.crt
COPY certs/server.key /var/lib/postgresql/certs/server.key

# 5. Ajustar permissões dentro do container
RUN chown postgres:postgres /var/lib/postgresql/certs/* \
    && chmod 600 /var/lib/postgresql/certs/server.key \
    && chmod 644 /var/lib/postgresql/certs/server.crt \
    && chmod 644 /var/lib/postgresql/certs/root.crt

# 6. Configurar o PostgreSQL para usar SSL via postgresql.conf
#    Vamos criar um arquivo personalizado de configuração e sobrepor o padrão.
COPY postgres.conf /etc/postgresql/postgresql.conf

# 7. Mudar para usuário postgres para iniciar o serviço
USER postgres

# 8. Ao iniciar, apontar o postgres para usar nosso postgresql.conf
CMD ["postgres", "-c", "config_file=/etc/postgresql/postgresql.conf"]
