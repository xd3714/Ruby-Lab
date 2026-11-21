require "sinatra"
require "builder"

set :port, 4567

CSS = <<~CSS
  * { box-sizing: border-box; }

  body {
    margin: 0;
    background: #0b1020;
    color: #e7edff;
    font-family: Arial, sans-serif;
  }

  header {
    background: #111a2d;
    border-bottom: 1px solid #283750;
    padding: 20px 30px;
    font-size: 22px;
    font-weight: bold;
  }

  header span { color: #50e4dc; }
  .layout { display: flex; min-height: 100vh; }

  aside {
    width: 235px;
    padding: 20px;
    background: #10182a;
    border-right: 1px solid #283750;
  }

  aside a {
    display: block;
    color: #b8c8e5;
    text-decoration: none;
    padding: 11px;
    margin: 4px 0;
    border-radius: 8px;
  }

  aside a:hover { background: #20304a; color: white; }

  main {
    width: 100%;
    max-width: 1050px;
    padding: 35px;
  }

  h1 { font-size: 38px; }
  h2 { margin-top: 35px; }
  p { color: #bac8df; line-height: 1.8; }
  .muted { color: #91a3c4; }

  .card {
    background: #121b2d;
    border: 1px solid #293a55;
    border-radius: 14px;
    padding: 20px;
    margin: 15px 0;
  }

  .grid {
    display: grid;
    grid-template-columns: repeat(2, minmax(0, 1fr));
    gap: 14px;
  }

  pre {
    background: #080e19;
    border: 1px solid #27364e;
    padding: 18px;
    border-radius: 12px;
    overflow-x: auto;
    color: #8de5dc;
    line-height: 1.7;
    white-space: pre-wrap;
  }

  code { color: #8de5dc; }

  .tag {
    color: #50e4dc;
    border: 1px solid #34506c;
    display: inline-block;
    padding: 6px 10px;
    border-radius: 20px;
  }

  .btn {
    display: inline-block;
    padding: 10px 15px;
    margin: 5px;
    border-radius: 9px;
    background: #67a8ff;
    color: #091322;
    text-decoration: none;
    font-weight: bold;
  }

  .btn:hover { filter: brightness(1.15); }

  .scene {
    background: #080e19;
    border: 1px solid #27364e;
    border-radius: 12px;
    padding: 10px;
    margin: 15px 0;
  }

  footer {
    border-top: 1px solid #283750;
    padding: 30px;
    text-align: center;
    color: #91a3c4;
  }

  @media(max-width: 750px) {
    .layout { flex-direction: column; }
    aside { width: 100%; }
    main { padding: 20px; }
    .grid { grid-template-columns: 1fr; }
  }
CSS

LESSONS = {
  "html" => {
    title: "HTML: estructura de una web",
    description: "HTML define los elementos que componen una página web.",
    code: <<~CODE
      <h1>Mi título</h1>
      <p>Un párrafo de texto.</p>
      <button>Presionar</button>
      <div>Un contenedor</div>
    CODE
  },
  "variables" => {
    title: "Variables",
    description: "Las variables guardan valores para reutilizarlos.",
    code: <<~CODE
      nombre = "Pelota"
      velocidad = 5
      color = "cyan"

      puts nombre
      puts velocidad
    CODE
  },
  "css" => {
    title: "CSS: diseño y estilo",
    description: "CSS controla colores, tamaños, posiciones y apariencia.",
    code: <<~CODE
      body {
        background: #0b1020;
        color: white;
      }

      .boton {
        padding: 12px;
        border-radius: 10px;
      }
    CODE
  },
  "svg" => {
    title: "SVG: gráficos vectoriales",
    description: "SVG permite construir dibujos con coordenadas y formas.",
    code: <<~CODE
      <svg viewBox="0 0 200 100">
        <circle cx="50" cy="50" r="25" fill="cyan"/>
        <rect x="100" y="25" width="50" height="50" fill="blue"/>
      </svg>
    CODE
  },
  "animacion" => {
    title: "Animar SVG",
    description: "Puedes mover, girar o cambiar el tamaño de objetos.",
    code: <<~CODE
      @keyframes mover {
        from { transform: translateX(0); }
        to { transform: translateX(300px); }
      }

      .objeto {
        animation: mover 3s infinite alternate;
      }
    CODE
  },
  "peerjs" => {
    title: "PeerJS: conectar dispositivos",
    description: "PeerJS facilita conexiones entre navegadores usando WebRTC.",
    code: <<~CODE
      const peer = new Peer();

      peer.on("open", id => {
        console.log("Mi ID:", id);
      });

      const connection = peer.connect(remoteID);

      connection.on("open", () => {
        connection.send({ x: 100, y: 50 });
      });
    CODE
  },
  "pantallas" => {
    title: "Mover objetos entre pantallas",
    description: "Puedes enviar coordenadas y estado para recrear un objeto en otro dispositivo.",
    code: <<~CODE
      {
        "x": 500,
        "y": 120,
        "velocityX": 4,
        "velocityY": 0,
        "color": "cyan"
      }
    CODE
  }
}

def code_block(x, source)
  x.pre do
    x.code(source)
  end
end

def render_site(lesson, ball_x, color)
  x = Builder::XmlMarkup.new(indent: 2)
  lesson = lesson.to_s
  ball_x = ball_x.to_i.clamp(5, 95)
  colors = %w[cyan red yellow blue green magenta]
  color = colors.include?(color) ? color : "cyan"

  x.declare!(:DOCTYPE, :html)
  x.html(lang: "es") do
    x.head do
      x.meta(charset: "utf-8")
      x.meta(name: "viewport", content: "width=device-width, initial-scale=1")
      x.title("RubyLab | Aprende Web")
      x.style { x << CSS }
    end

    x.body do
      x.header do
        x << "Ruby"
        x.span("Lab")
        x.span("  |  Aprende · Construye · Explora")
      end

      x.div(class: "layout") do
        x.aside do
          x.h3("CURSO")
          x.a("🏠 Inicio", href: "/")
          x.a("📄 HTML", href: "/?lesson=html")
          x.a("📦 Variables", href: "/?lesson=variables")
          x.a("🎨 CSS", href: "/?lesson=css")
          x.a("🔷 SVG", href: "/?lesson=svg")
          x.a("✨ Animación", href: "/?lesson=animacion")
          x.a("🌐 PeerJS", href: "/?lesson=peerjs")
          x.a("🖥️ Pantallas", href: "/?lesson=pantallas")
          x.a("🧪 Laboratorio", href: "/lab")
        end

        x.main do
          if lesson == "inicio"
            x.div(class: "card") do
              x.span("GUÍA INTERACTIVA", class: "tag")
              x.h1("Aprende a construir experiencias web")
              x.p("Explora HTML, variables, CSS, SVG, animaciones y comunicación entre dispositivos.")
            end

            x.h2("Ruta de aprendizaje")

            [
              ["01", "HTML", "Estructura de una página"],
              ["02", "Variables", "Datos y valores"],
              ["03", "CSS", "Diseño visual"],
              ["04", "SVG", "Gráficos vectoriales"],
              ["05", "Animación", "Movimiento de objetos"],
              ["06", "PeerJS", "Conexión entre navegadores"],
              ["07", "Pantallas", "Transferencia de objetos"]
            ].each do |item|
              x.div(class: "card") do
                x.h3("#{item[0]} · #{item[1]}")
                x.p(item[2])
              end
            end

          elsif LESSONS[lesson]
            current = LESSONS[lesson]
            x.h1(current[:title])
            x.p(current[:description])
            x.h2("Ejemplo")
            code_block(x, current[:code])

            x.div(class: "card") do
              x.h3("¿Qué debes aprender?")
              x.p(current[:description])
              x.p("Prueba modificar el ejemplo y observa cómo cambia el resultado.")
            end

          else
            x.h1("RubyLab")
            x.p("Selecciona una lección del menú.")
          end

          if lesson == "svg" || lesson == "animacion"
            x.h2("Vista SVG")
            x.div(class: "scene") do
              x.svg(width: "100%", height: "170", viewBox: "0 0 500 170") do
                x.rect(width: "500", height: "170", fill: "#080e19", rx: "12")
                x.circle(cx: ball_x * 5, cy: "85", r: "20", fill: color)
              end
            end
            x.a("Abrir laboratorio interactivo", class: "btn", href: "/lab")
          end

          if lesson == "peerjs" || lesson == "pantallas"
            x.div(class: "card") do
              x.h3("Conceptos clave")
              x.p("Peer ID · Conexión · Datos · WebRTC · Coordenadas · Estado del objeto")
              x.a("Probar simulación", class: "btn", href: "/lab")
            end
          end
        end
      end

      x.footer("RubyLab · Sitio generado utilizando Ruby")
    end
  end

  x.target!
end

get "/" do
  lesson = params[:lesson] || "inicio"
  ball_x = params[:x] || 50
  color = params[:color] || "cyan"
  render_site(lesson, ball_x, color)
end

get "/lab" do
  x = Builder::XmlMarkup.new(indent: 2)
  x.declare!(:DOCTYPE, :html)
  x.html(lang: "es") do
    x.head do
      x.meta(charset: "utf-8")
      x.meta(name: "viewport", content: "width=device-width, initial-scale=1")
      x.title("RubyLab | Laboratorio")
      x.style { x << CSS }
    end

    x.body do
      x.header do
        x << "Ruby"
        x.span("Lab")
      end

      x.main do
        x.h1("Laboratorio SVG")
        x.p("Modifica la posición y el color de tu objeto.")

        colors = %w[cyan red yellow blue green magenta]
        current_color = params[:color] || "cyan"
        current_color = "cyan" unless colors.include?(current_color)
        position = (params[:x] || 10).to_i.clamp(5, 95)

        x.div(class: "card") do
          x.h3("Posición X: #{position}")
          colors.each do |c|
            x.a(c.capitalize, class: "btn", href: "/lab?color=#{c}&x=#{position}")
          end
        end

        x.div(class: "card") do
          x.h3("Mover objeto")
          [10, 25, 50, 75, 90].each do |pos|
            x.a("#{pos}%", class: "btn", href: "/lab?color=#{current_color}&x=#{pos}")
          end
        end

        x.div(class: "scene") do
          x.svg(width: "100%", height: "180", viewBox: "0 0 500 180") do
            x.rect(width: "500", height: "180", fill: "#080e19", rx: "12")
            x.circle(cx: position * 5, cy: "90", r: "22", fill: current_color)
          end
        end

        x.h2("Datos del objeto")
        code_block(x, "objeto = { x: #{position}, y: 90, color: \"#{current_color}\" }")
        x.a("← Volver al curso", class: "btn", href: "/")
      end
    end
  end

  x.target!
end
