require 'rational'

class NotSquaredMatrix < Exception
  def message
   "Matrix is not squared!"
  end
end

class Matrix
  attr_accessor :matrix

  # The matrix is initialized with an array where each element is an
  # array that represents a row, and each element of a row, a column.
  def initialize matrix
    @matrix = matrix
  end

  # Returns true if the matrix has the same number of columns in each row.
  def well_formed?
    @well_formed ||= matrix.all? { |row| row.size == cols }
  end

  def inspect
    matrix.map { |row| "( #{row.join(' ')} )" }.join("\n")
  end

  def cols
    @cols ||= matrix.first.size
  end

  def rows
    @rows ||= matrix.size
  end

  def dimension
    "#{rows} x #{cols}"
  end

  def squared?
    rows == cols and well_formed?
  end

  # Returns a copy of the original matrix without the row i and the column j.
  def trim_matrix(i,j)
    new_matrix = matrix.map { |row| row.dup }
    new_matrix.delete_at(i)
    new_matrix.each { |row| row.delete_at(j) }
    self.class.new(new_matrix)
  end

  # The determinant is calculated with cofactors. It´s the sum of the product
  # of each element in the first row (alternating the sign) times the
  # determinant of the trim_matrix
  def determinant
    raise NotSquaredMatrix unless squared?
    return matrix[0][0] if dimension == "1 x 1"

    det = 0
    rows.times do |i|
      det += (-1 ** i) * matrix[0][i] * trim_matrix(0,i).determinant
    end
    det
  end

  # Returns the row i as a vector
  def row(i)
    matrix[i].to_v
  end

  # Returns the column j as a vector
  def column(j)
    col = Vector.new([])
    matrix.each_index do |i|
      col.elements << matrix[i][j]
    end
    col
  end

  # Returns the product of two matrixes.
  def *(m2)
    raise ArgumentError unless cols == m2.rows

    result = Matrix.new([])
    rows.times do |i|
      result.matrix[i] = []
      cols.times do |j|
        result.matrix[i][j] = row(i) * m2.column(j)
      end
    end
    result
  end

  # Returns the adjugate matrix.
  def adjugate
    adjugate = Matrix.new([])
    rows.times do |i|
      adjugate.matrix[i] = []
      cols.times do |j|
        adjugate.matrix[i][j] = (-1 ** (i+j)) * trim_matrix(j,i).determinant
      end
    end
    adjugate
  end

  # Returns a matrix multiplied by a scalar.
  def dot_product(k)
    result = Matrix.new([])
    result.matrix = matrix.collect {|row| row.collect {|col| col * k }}
    result
  end

  # Returns the inverse of a matrix.
  def inverse
    adjugate.dot_product(Rational(1,determinant))
  end

end

class Vector
  attr_accessor :elements

  def same_dimension?(v2)
    elements.size == v2.elements.size
  end

  def initialize(elements)
    @elements = elements
  end

  def inspect
    "(#{elements.join(', ')})"
  end

  # Returns the scalar product of two vectors
  def *(v2)
    raise WrongArgumentError unless same_dimension?(v2)
    product = 0
    elements.each_index do |i|
      product += v2.elements[i] * elements[i]
    end
    product
  end
end

class Array
  def to_v
    Vector.new(self)
  end
end
