Practice-projects
=================

Until we get this running, some prime calculating here:

#Primes to n: identifies prime numbers up to a given n

# Set max number to test up to
puts "PRIMES TO N"
puts "Prime numbers up to what limit?"
n = gets.chomp.to_i

# cutting n to approximate limit when running in repl.it
    if n > 1000
        puts "I'm sorry, I'm afraid I can't do that. How about up to 1000?"
        n = 1000
    end

# Create array for storing primes - used for testing integers and for final printout
# So far seed number is necessary; empty array causes problems with primes.each
primes = [2]

# Loop that calls each integer for comparison
(3..n).each do |i|
#print "i", i    
    
    if primes.any? { |p| i % p == 0} then
        #puts
        next
    else
        #puts "pass"
        primes.push(i) if i != primes [primes.size - 1]
    end
 
end
puts
primes.each { |pr| print pr, "\t" }
