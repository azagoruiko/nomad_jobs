FROM jupyter/all-spark-notebook

RUN wget https://repo1.maven.org/maven2/org/apache/spark/spark-hadoop-cloud_2.13/3.4.0/spark-hadoop-cloud_2.13-3.4.0.jar
RUN wget https://repo1.maven.org/maven2/org/postgresql/postgresql/42.5.4/postgresql-42.5.4.jar
RUN wget https://repo1.maven.org/maven2/mysql/mysql-connector-java/8.0.30/mysql-connector-java-8.0.30.jar
RUN wget https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-aws/3.3.6/hadoop-aws-3.3.6.jar
RUN wget https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk/1.12.641/aws-java-sdk-1.12.641.jar
RUN wget https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-core/1.12.641/aws-java-sdk-core-1.12.641.jar
RUN wget https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-s3/1.12.641/aws-java-sdk-s3-1.12.641.jar
USER root
RUN mv *.jar /usr/local/spark/jars/
