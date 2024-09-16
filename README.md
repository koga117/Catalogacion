# Proyecto de E-commerce - Documentación y Despliegue

Este repositorio contiene los archivos necesarios para desplegar los servicios de autenticación, gestión de productos y pedidos, y el frontend del proyecto, utilizando LocalStack, API Gateway, DynamoDB y otras herramientas.

## Tabla de Contenidos
1. [Prerequisitos](#prerequisitos)
2. [Clonacion del Repositorio](#clonacion-del-repositorio)
3. [Despliegue de Servicios](#despliegue-de-servicios)
4. [Autenticación y Funciones Lambda](#autenticacion-y-funciones-lambda)
5. [Frontend - Angular](#frontend---angular)
6. [Backend - Gestion de Pedidos (Node.js/Express)](#backend---gestion-de-pedidos-nodejsexpress)
7. [Backend - Catalogo de Productos (Spring Boot)](#backend---catalogo-de-productos-spring-boot)
8. [Arquitectura](#arquitectura)

---

### **Prerequisitos**
Antes de comenzar, asegúrate de tener lo siguiente instalado:
- Docker
- Node.js y npm
- Angular CLI (para frontend)
- AWS CLI configurado
- Git
- Java 17+ (para Spring Boot)

---

### **Clonacion del Repositorio**
Clona el repositorio en tu máquina local usando el siguiente comando:

```bash
git clone https://github.com/usuario/proyecto-ecommerce.git
cd proyecto-ecommerce
```

---


### **Despliegue de Servicios**

A continuación, se detallan los pasos para desplegar los distintos componentes del proyecto. Puedes descargar directamente los archivos o clonar el repositorio completo para ejecutarlos desde tu entorno local.

#### Tabla de Pasos para Despliegue

| **Nombre del Paso**      | **Descripción**                                                                | **URL**                                                                 |
|--------------------------|--------------------------------------------------------------------------------|-------------------------------------------------------------------------|
| **Diagrama**             | Diagrama de arquitectura de alto nivel.                                         | [Diagrama](https://github.com/koga117/Catalogacion/blob/main/Diagrama/Arquitectura.png)  |
| **Autenticación**        | Despliegue de funciones Lambda para autenticación de usuarios.                 | [Autenticación](https://github.com/koga117/Catalogacion/blob/main/Autenticacion)  |
| **Diseño Nube**          | Configuración de LocalStack, API Gateway y despliegue de funciones Lambda.      | [Diseño Nube](https://github.com/koga117/Catalogacion/blob/main/Dise%C3%B1oNube)  |
| **Frontend Angular**     | Proyecto frontend en Angular para el e-commerce.                                | [Frontend Angular](https://github.com/koga117/ecomerce-frontend)  |
| **Backend Pedidos**      | Servicio backend para gestión de pedidos en Node.js/Express.                    | [Backend Pedidos](https://github.com/koga117/order-management-service)  |
| **Backend Productos**    | Servicio backend para gestión de productos en Spring Boot.                      | [Backend Productos](URL_A_DEFINIR) |

---

### **Pasos Detallados de Despliegue**

### **Diseño Nube**

1.**Configuración de LocalStack**: Para ejecutar LocalStack en Docker, usa el siguiente comando:

```bash
docker-compose up
```

---

2. **Desplegar las funciones Lambda**: Ejecuta el siguiente comando para desplegar las funciones Lambda:

    ```bash
    ./deploy_lambdas.sh
    ```

---

3. **Verificar el log de casos de prueba**: Después de ejecutar el comando anterior, verifica el archivo `output.txt` para revisar los logs con los casos de prueba ejecutados. Este archivo debería contener información detallada sobre el despliegue y los resultados de las pruebas.

    ```bash
    cat output.txt
    ```

---

Asegúrate de que el archivo `output.txt` esté en el directorio correcto y revisa el contenido para confirmar que las funciones Lambda se han desplegado correctamente y los casos de prueba se han ejecutado como se esperaba.

---

### **Explicacion detallada funcionalidad nube**
  En un entorno de nube real, como AWS, tu función Lambda se desplegaría y ejecutaría en el servicio AWS Lambda. Los pasos serían similares, pero en lugar de utilizar LocalStack para simular la infraestructura, usarías   la consola de AWS o herramientas como AWS CLI para interactuar con los servicios reales.

  AWS Lambda: Implementarías tu función Lambda en la consola de AWS o mediante AWS CLI. AWS Lambda se encargaría de ejecutar el código en respuesta a los eventos que recibe.
  IAM Roles: En un entorno real, deberías asignar un rol de IAM adecuado a la función Lambda para permitirle acceder a otros recursos de AWS si es necesario.
  AWS CLI: Utilizarías el CLI de AWS para desplegar y administrar tu función Lambda en la nube real.

---


#### **Autenticacion y Funciones Lambda**

1. **Desplegar funciones de autenticación**:
   Para desplegar las funciones de autenticación (autorizar, registrar y login), sigue estos pasos:

   ```bash
   cd Autenticacion
   ./deploy_lambdas.sh
   ```

---

#### Archivos relevantes:

- **Authorization.zip**: Función Lambda que valida tokens JWT. [Descargar](https://github.com/koga117/Catalogacion/blob/main/Autenticacion/Authorization.zip)
- **loginUser.zip**: Función Lambda para el inicio de sesión de usuarios registrados. [Descargar](https://github.com/koga117/Catalogacion/blob/main/Autenticacion/loginUser.zip)
- **register.zip**: Función Lambda que registra nuevos usuarios. [Descargar](https://github.com/koga117/Catalogacion/blob/main/Autenticacion/register.zip)

---

#### **Frontend - Angular**

1. **Instalar dependencias**:
   Primero, asegúrate de tener instalado Angular CLI y luego instala las dependencias del proyecto:

   ```bash
   cd ecomerce-frontend
   npm install
   ```

---

2.Subir el proyecto: Para ejecutar el frontend en tu entorno local:

```bash
ng serve --open
```

---

El proyecto se abrirá en tu navegador en [http://localhost:4200/](http://localhost:4200/).

#### Backend - Gestion de Pedidos (Node.js/Express)

1.Instalar dependencias: Navega al directorio del backend de gestión de pedidos e instala las dependencias:

```bash
cd order-management-service
npm install
```

---

2.Subir el proyecto: Para ejecutar el servidor de Express.js:

```bash
node app.js
```

---

El servidor se ejecutará en [http://localhost:3000/](http://localhost:3000/).

#### Backend - Catalogo de Productos (Spring Boot)

1.Subir el proyecto en el puerto 8080: Este servicio debe ser ejecutado en tu IDE de preferencia, como IntelliJ o Eclipse. Asegúrate de configurarlo para que corra en el puerto 8080.

## Arquitectura

El diagrama de arquitectura en alto nivel para el proyecto está disponible aquí:

[Diagrama de Arquitectura](https://github.com/koga117/Catalogacion/blob/main/Diagrama/Arquitectura.png)
