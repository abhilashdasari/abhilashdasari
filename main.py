from flask import Flask, render_template, send_file
import os

app = Flask(__name__)

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/download-cv')
def download_cv():
    # This route would serve the CV file if available
    return render_template('index.html')

@app.route('/skills/programming')
def programming_skills():
    return render_template('skills/programming.html')

@app.route('/skills/computational-biology')
def computational_biology():
    return render_template('skills/computational_biology.html')

@app.route('/blog')
def blog():
    # Placeholder for future blog posts
    posts = []
    return render_template('blog/index.html', posts=posts)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)