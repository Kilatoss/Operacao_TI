# 🧠 Operação — Jogo Interativo de Anatomia para Crianças

Este projeto é uma reinterpretação educativa do clássico jogo "Operação", desenvolvido com **Arduino** e **Processing**, que visa ensinar às crianças os órgãos do corpo humano de forma interativa e lúdica.
Feito no ãmbito da disciplina de Tecnologias de Interface, do Mestrado de Design e Multimédia da Faculdade de Ciências e Tecnologia da Universidade de Coimbra.

## 🎯 Objetivos

- Estimular a aprendizagem da anatomia básica através de interação física e digital.
- Promover o raciocínio lógico, a coordenação motora e a memorização em crianças.
- Explorar o potencial das tecnologias de interface física no contexto educativo.
- Criar uma ligação direta entre o mundo físico (sensores, LEDs) e digital (interface gráfica).

## 🛠 Tecnologias Usadas

- **Arduino UNO** — Leitura de sensores e controlo de LEDs.
- **Processing** — Interface gráfica interativa com feedback visual e sonoro.
- **Componentes eletrónicos** — LDRs, LEDs, sensor ultrassónico HC-SR04, resistências, breadboards.
- **Materiais físicos** — Estrutura de K-Line, caixas dos órgãos e imagem ilustrativa do corpo.

## ⚙️ Como Usar

1. **Montar o circuito** com os sensores e LEDs conforme o esquema disponível em `hardware/`.
2. **Carregar o código Arduino** (`arduino/Operacao_Arduino.ino`) para a placa.
3. **Abrir o Processing** e correr o sketch principal (`processing/Operacao_Processing.pde`).
4. **Interagir com o protótipo**:
   - O jogo inicia quando é detetada a presença de um jogador.
   - A interface indica qual órgão deve ser colocado.
   - Feedback visual (LEDs) e sonoro (sucesso ou erro) reforçam a ação.

## 🎓 Potencial Educativo

Este protótipo serve como ferramenta de apoio ao ensino em contexto de sala de aula ou exposição interativa. Permite adaptar facilmente os conteúdos e é escalável para outras áreas do corpo humano ou outros temas didáticos.

## 📄 Documentação

A documentação completa do projeto encontra-se em [`docs/Milestone4.pdf`](docs/Milestone4.pdf), incluindo a contextualização, materiais utilizados, funcionamento técnico e reflexão final.

## 🤝 Autoria

Projeto desenvolvido no âmbito do curso de **Design e Multimédia** da **Faculdade de Ciências e Tecnologia da Universidade de Coimbra**.

- Afonso Caldeira Cerca de Alves Martins  
- Ana Raquel Reis Quintela  
- Marta Alves Teixeira

## 📜 Licença

Este projeto está licenciado sob a licença MIT. Consulta o ficheiro [`LICENSE`](LICENSE) para mais informações.