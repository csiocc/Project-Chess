#!/bin/bash
# UML-ähnliches Diagramm aus lib/**/*.rb (Klassen, Module, Vererbung, Mixins)
set -euo pipefail
shopt -s globstar nullglob

files=(lib/**/*.rb lib/*.rb)
if [ ${#files[@]} -eq 0 ]; then
  echo "❌ Keine Ruby-Dateien in lib/ gefunden."
  exit 1
fi

echo "🔎 Analysiere ${#files[@]} Dateien…"

ruby - "$@" <<'RUBY' "${files[@]}" > uml.dot
require "set"
files = ARGV

classes  = Set.new    # "Foo::Bar"
modules  = Set.new    # "Baz"
inherits = Set.new    # ["child","parent"]
includes = Set.new    # ["owner","mixin"]
scope    = []         # Namespace-Stack

def fqname(scope, name)
  return name if name.include?("::")
  (scope + [name]).join("::")
end

files.each do |path|
  next unless File.file?(path)
  File.foreach(path) do |line|
    l = line.sub(/#.*$/, "") # Kommentar grob entfernen

    # class << self / class << obj überspringen
    next if l =~ /^\s*class\s*<</

    # module Foo(::Bar)?
    if l =~ /^\s*module\s+([A-Z]\w*(?:::\w+)*)/
      mod = $1.strip
      mod = fqname(scope, mod) unless mod.include?("::") && scope.empty?
      modules << mod
      scope << mod
      next
    end

    # class Foo(::Bar)? (< Parent)?
    if l =~ /^\s*class\s+([A-Z]\w*(?:::\w+)*)(?:\s*<\s*([A-Z]\w*(?:::\w+)*))?/
      cls, parent = $1.strip, $2
      cls = fqname(scope, cls) unless cls.include?("::") && scope.empty?
      classes << cls
      inherits << [cls, parent.strip] if parent
      scope << cls
      next
    end

    # include Mixin
    if l =~ /^\s*include\s+([A-Z]\w*(?:::\w+)*)/
      mixin = $1.strip
      owner = scope.last
      includes << [owner, mixin] if owner
      next
    end

    # scope-Ende
    if l =~ /^\s*end\b/
      scope.pop if scope.any?
      next
    end
  end
end

# Referenzierte Supertypen/Mixins als Knoten sicherstellen
inherits.each do |child, parent|
  next unless parent
  classes << parent unless classes.include?(parent) || modules.include?(parent)
end
includes.each do |owner, mixin|
  next unless mixin
  modules << mixin unless classes.include?(mixin) || modules.include?(mixin)
end

def esc(s) # DOT-Safe
  s.to_s.gsub('"','\"')
end

puts 'digraph "Ruby UML" {'
puts '  rankdir=LR;'
puts '  graph [splines=true, overlap=false];'
puts '  node  [shape=box, style="rounded,filled", fillcolor="#f8f9fa", fontsize=10];'

(classes.to_a.sort).each do |c|
  # Kein Record-Label, kein <>, stattdessen Zeilenumbruch + Guillemets
  puts %(  "#{esc(c)}" [label="#{esc(c)}\\n«class»"];)
end

(modules.to_a.sort).each do |m|
  puts %(  "#{esc(m)}" [shape=folder, label="#{esc(m)}\\n«module»", fillcolor="#eef6ff"];)
end

# Vererbung (leerers Dreieck), Duplikate wurden per Set vermieden
inherits.each do |child, parent|
  next unless child && parent
  puts %(  "#{esc(child)}" -> "#{esc(parent)}" [arrowhead=empty, arrowsize=1.0, penwidth=1.2];)
end

# Mixins (gestrichelt)
includes.each do |owner, mixin|
  next unless owner && mixin
  puts %(  "#{esc(owner)}" -> "#{esc(mixin)}" [style=dashed, arrowhead=vee, arrowsize=0.8, label="include"];)
end

puts "}"
RUBY

echo "✅ uml.dot erzeugt."

if command -v dot >/dev/null 2>&1; then
  dot -Tsvg uml.dot -o uml.svg
  dot -Tpng uml.dot -o uml.png
  echo "✅ Diagramme erstellt: uml.svg, uml.png"
else
  echo "⚠️ Graphviz 'dot' nicht gefunden. Installiere es z. B.: sudo apt install graphviz"
  echo "Danach: dot -Tsvg uml.dot -o uml.svg"
fi
